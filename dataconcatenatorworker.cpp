#include "dataconcatenatorworker.h"


DataConcatenatorWorker::DataConcatenatorWorker(const QString &sourcePath, const QString &targetPath, int pollIntervalMs, QObject *parent)
    : QObject(parent), m_sourcePath(sourcePath), m_targetPath(targetPath)
{
    QFileInfo info(m_sourcePath);
    if (info.exists() && info.size() > 0) {
        m_lastCommittedMod = info.lastModified();
        m_lastCommittedSize = info.size();
        m_lastCommittedHash = computeFileHash(m_sourcePath);
    }

    connect(&m_timer, &QTimer::timeout, this, &DataConcatenatorWorker::pollFile);
    m_timer.start(pollIntervalMs);
}

void DataConcatenatorWorker::pollFile() {
    // Force NFS close-to-open attribute cache refresh
    QFile probe(m_sourcePath);
    if (!probe.open(QIODevice::ReadOnly)) {
        return;
    }
    probe.close();

    QFileInfo info(m_sourcePath);
    info.refresh();

    if (!info.exists() || info.size() == 0) {
        return;
    }

    const QDateTime currentMod = info.lastModified();
    const qint64 currentSize = info.size();

    // Check if metadata changed, or if we are tracking an in-progress write
    if (currentMod != m_lastCommittedMod || currentSize != m_lastCommittedSize || m_pendingWrite) {
        if (!m_pendingWrite || currentMod != m_pendingMod || currentSize != m_pendingSize) {
            // File is newly modified or still growing; wait for the next tick to settle
            m_pendingWrite = true;
            m_pendingMod = currentMod;
            m_pendingSize = currentSize;
            return;
        }

        // Metadata remained identical across two ticks: remote overwrite has finished
        m_pendingWrite = false;

        const QByteArray currentHash = computeFileHash(m_sourcePath);
        if (currentHash.isEmpty()) {
            return; // Read failed during hash; retry on next tick
        }

        // Skip if file was touched without actual byte changes
        if (currentHash == m_lastCommittedHash) {
            m_lastCommittedMod = currentMod;
            m_lastCommittedSize = currentSize;
            return;
        }

        if (appendBinaryWithRollback()) {
            m_lastCommittedMod = currentMod;
            m_lastCommittedSize = currentSize;
            m_lastCommittedHash = currentHash;
            emit binaryAppended(currentSize, currentHash);
        }
    }
}

QByteArray DataConcatenatorWorker::computeFileHash(const QString &path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        return {};
    }

    QCryptographicHash hasher(QCryptographicHash::Sha256);
    constexpr qint64 chunkSize = 65536;
    while (!file.atEnd()) {
        QByteArray chunk = file.read(chunkSize);
        if (chunk.isEmpty() && file.error() != QFileDevice::NoError) {
            return {};
        }
        hasher.addData(chunk);
    }
    return hasher.result();
}

bool DataConcatenatorWorker::appendBinaryWithRollback() {
    QFile src(m_sourcePath);
    if (!src.open(QIODevice::ReadOnly)) {
        emit errorOccurred("Failed to open NFS source: " + src.errorString());
        return false;
    }

    QFile dst(m_targetPath);
    if (!dst.open(QIODevice::WriteOnly | QIODevice::Append)) {
        emit errorOccurred("Failed to open target file: " + dst.errorString());
        return false;
    }

    const qint64 originalDstSize = dst.size();
    constexpr qint64 chunkSize = 65536;

    while (!src.atEnd()) {
        QByteArray buffer = src.read(chunkSize);
        if (buffer.isEmpty() && src.error() != QFileDevice::NoError) {
            dst.resize(originalDstSize); // Roll back partial append on NFS drop
            emit errorOccurred("NFS read error during append: " + src.errorString());
            return false;
        }
        if (dst.write(buffer) != buffer.size()) {
            dst.resize(originalDstSize); // Roll back partial append on disk error
            emit errorOccurred("Target write error: " + dst.errorString());
            return false;
        }
    }

    dst.flush();
    return true;
}

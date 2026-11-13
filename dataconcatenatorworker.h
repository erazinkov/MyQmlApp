#ifndef DATACONCATENATORWORKER_H
#define DATACONCATENATORWORKER_H

#include <QObject>
#include <QTimer>
#include <QFileInfo>
#include <QFile>
#include <QDateTime>
#include <QCryptographicHash>

class DataConcatenatorWorker : public QObject
{
    Q_OBJECT
public:
    explicit DataConcatenatorWorker(const QString &sourcePath,
                                    const QString &targetPath,
                                    int pollIntervalMs = 2000,
                                    QObject *parent = nullptr);

signals:
    void binaryAppended(qint64 bytesAppended, const QByteArray &sha256);
    void errorOccurred(const QString &error);

private slots:
    void pollFile();

private:
    QString m_sourcePath;
    QString m_targetPath;
    QTimer m_timer{this};

    QDateTime m_lastCommittedMod;
    qint64 m_lastCommittedSize = -1;
    QByteArray m_lastCommittedHash;

    bool m_pendingWrite = false;
    QDateTime m_pendingMod;
    qint64 m_pendingSize = -1;


    QByteArray computeFileHash(const QString &path);
    bool appendBinaryWithRollback();
};

#endif // DATACONCATENATORWORKER_H

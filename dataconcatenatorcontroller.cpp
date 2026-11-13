#include "dataconcatenatorcontroller.h"

DataConcatenatorController::DataConcatenatorController(QObject *parent)
    : QObject(parent)
{
    m_thread = new QThread(this);
    m_worker = new DataConcatenatorWorker("/misc/agpf_nap/adcm.dat", "/home/egor/shares/tmp/test.dat", 2'000);
    m_worker->moveToThread(m_thread);

    connect(m_worker, &DataConcatenatorWorker::binaryAppended, this, [](qint64 bytes, const QByteArray &hash) {
        qDebug() << "Appended" << bytes << "bytes. SHA256:" << hash.toHex();
    });
//    connect(m_worker, &DataConcatenatorWorker::errorOccurred, this, &DataConcatenatorController::errorOccurred);

    // Ensure thread and worker cleanup
    connect(m_thread, &QThread::finished, m_worker, &QObject::deleteLater);

    m_thread->start();
}

DataConcatenatorController::~DataConcatenatorController()
{
    m_thread->quit();
    m_thread->wait();
}

#include "processingcontroller.h"

ProcessingController::ProcessingController(QObject *parent)
    : QObject{parent}
{
    m_thread = new QThread(this);
    m_worker = new ProcessingWorker;
    m_worker->moveToThread(m_thread);
    // Connect signals from controller to worker slots (queued connection by default)
    connect(this, &ProcessingController::operateAddData, m_worker, &ProcessingWorker::handleAddData);
    connect(this, &ProcessingController::operateProcessData, m_worker, &ProcessingWorker::handleProcessData);

    connect(m_worker, &ProcessingWorker::processData, this, &ProcessingController::processData);
    // Ensure thread and worker cleanup
    connect(m_thread, &QThread::finished, m_worker, &QObject::deleteLater);

    m_thread->start();
}

ProcessingController::~ProcessingController()
{
    m_thread->quit();
    m_thread->wait();
}

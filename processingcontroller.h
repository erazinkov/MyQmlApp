#ifndef PROCESSINGCONTROLLER_H
#define PROCESSINGCONTROLLER_H

#include <QObject>
#include <QThread>
#include <QVariantHash>

#include "processingworker.h"

class ProcessingController : public QObject
{
    Q_OBJECT
public:
    explicit ProcessingController(QObject *parent = nullptr);
    ~ProcessingController() override;

signals:
    Q_INVOKABLE void operateAddData(QList<QVariantHash> data);
    Q_INVOKABLE void operateProcessData(QList<QVariantList> paths);

//    Q_INVOKABLE void addData(QList<QVariantHash> data);
    Q_INVOKABLE void processData(int index, int result, bool isProcess);
private:
    QThread *m_thread;
    ProcessingWorker *m_worker;
};

#endif // PROCESSINGCONTROLLER_H

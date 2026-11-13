#ifndef DATACONCATENATORCONTROLLER_H
#define DATACONCATENATORCONTROLLER_H

#include <QObject>

#include "dataconcatenatorworker.h"
#include <QThread>

class DataConcatenatorController : public QObject
{
    Q_OBJECT
public:
    explicit DataConcatenatorController(QObject *parent = nullptr);
    ~DataConcatenatorController() override;
signals:

private:
    QThread *m_thread;
    DataConcatenatorWorker *m_worker;

};

#endif // DATACONCATENATORCONTROLLER_H

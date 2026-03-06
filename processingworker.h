#ifndef PROCESSINGWORKER_H
#define PROCESSINGWORKER_H

#include <QObject>
#include <QGeoCoordinate>

class ProcessingWorker : public QObject
{
    Q_OBJECT
public:
    explicit ProcessingWorker(QObject *parent = nullptr);

public slots:
    void handleAddData(QList<QVariantHash> data);
    void handleProcessData(QList<QVariantList> paths);

signals:
    void processData(int index, int result, bool isProcess);

private:
    QList<QPair<QGeoCoordinate, QString>> m_gpsData;

};

#endif // PROCESSINGWORKER_H

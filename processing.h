#ifndef PROCESSING_H
#define PROCESSING_H

#include <QObject>
#include <QGeoCoordinate>

class Processing : public QObject
{
    Q_OBJECT
public:
    explicit Processing(QObject *parent = nullptr);

    Q_INVOKABLE void processDataTest1(const QList<QVariantList> &paths);
    Q_INVOKABLE void addData(const QList<QVariantHash> &data);
signals:
    Q_INVOKABLE void finished(int index, int result);
private:
    QList<QPair<QGeoCoordinate, QString>> m_gpsData;
};

#endif // PROCESSING_H

#include "processingworker.h"

#include <QGeoPolygon>

ProcessingWorker::ProcessingWorker(QObject *parent)
    : QObject{parent}
{

}

void ProcessingWorker::handleAddData(QList<QVariantHash> data)
{
    m_gpsData.clear();
    for (auto i{0}, j{0}; i < data.count(); i += 1) {
        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
            m_gpsData.append({QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j)});
        }
    }
}

void ProcessingWorker::handleProcessData(QList<QVariantList> paths)
{
    QList<QGeoPolygon> polygons(paths.count());
    for (auto pathIdx{0}; pathIdx < paths.count(); ++pathIdx) {
        for (auto pointIdx{0}; pointIdx < paths.at(pathIdx).count(); ++pointIdx) {
            QGeoCoordinate c{paths.at(pathIdx).at(pointIdx).value<QGeoCoordinate>()};
            polygons[pathIdx].addCoordinate(c);
        }
    }

    QList<int> pointsInPolygons(polygons.count());
    for (auto p{0}; p < polygons.count(); ++p) {
        for (auto i{0}; i < m_gpsData.count(); ++i) {
            if (polygons.at(p).contains(m_gpsData.at(i).first)) {
                pointsInPolygons[p] += 1;
            }
        }
        emit processData(p, pointsInPolygons.at(p));
    }

    for (auto i{0}; i < pointsInPolygons.count(); ++i) {
        qDebug() << i << pointsInPolygons.at(i);
    }
}

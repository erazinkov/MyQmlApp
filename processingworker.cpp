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

#include <QThread>

void ProcessingWorker::handleProcessData(QList<QVariantList> paths, int rows, int columns)
{
    auto distance{0.0};

    for (auto i{0}; i < m_gpsData.count() - 1; ++i) {
        auto c0{QGeoCoordinate{m_gpsData.at(i).first.latitude(), m_gpsData.at(i).first.longitude()}};
        auto c1{QGeoCoordinate{m_gpsData.at(i + 1).first.latitude(), m_gpsData.at(i).first.longitude()}};
        distance += c0.distanceTo(c1);
    }

    qDebug() << "Distance, m:" << distance;


    QList<QGeoPolygon> polygons(paths.count());
    for (auto pathIdx{0}; pathIdx < paths.count(); ++pathIdx) {
        for (auto pointIdx{0}; pointIdx < paths.at(pathIdx).count(); ++pointIdx) {
            QGeoCoordinate c{paths.at(pathIdx).at(pointIdx).value<QGeoCoordinate>()};
            polygons[pathIdx].addCoordinate(c);
        }
    }

    QList<int> pointsInPolygons(polygons.count());
    for (auto p{0}; p < polygons.count(); ++p) {
        emit processData(p, pointsInPolygons.at(p), true, rows, columns);
        QThread::currentThread()->msleep(500);
        for (auto i{0}; i < m_gpsData.count(); ++i) {
            if (polygons.at(p).contains(m_gpsData.at(i).first)) {
                pointsInPolygons[p] += 1;
            }
        }
        emit processData(p, pointsInPolygons.at(p), false, rows, columns);
    }

//    for (auto i{0}; i < pointsInPolygons.count(); ++i) {
//        qDebug() << i << pointsInPolygons.at(i);
//    }
}

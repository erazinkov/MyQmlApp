#include "processingworker.h"

#include <QGeoPolygon>

#include <fstream>
#include <string>
#include <QDateTime>

ProcessingWorker::ProcessingWorker(QObject *parent)
    : QObject{parent}
{

}

void ProcessingWorker::handleAddData(QList<QVariantHash> data)
{
    m_gpsData.clear();
//    for (auto i{0}, j{0}; i < data.count(); i += 1) {
//        QVariant v = data.at(i)["dt"];
//        QDateTime dt = v.toDateTime();
//        qDebug() << dt.timeSpec();          // May be Qt::LocalTime
//        qDebug() << dt.toMSecsSinceEpoch(); // Should match the original UTC time
//        qDebug() << QString::number(dt.toMSecsSinceEpoch()); // Should match the original UTC time
////        QDateTime dt = data.at(i)["dt"].toDateTime();
////        qDebug() << dt.toUTC().toString();
//    }
    for (auto i{0}, j{0}; i < data.count(); i += 1) {
        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
//            m_gpsData.append({QGeoCoordinate(data.at(i)["gps_lat"].value<double>(),
//                              data.at(i)["gps_lon"].value<double>()),
//                              QString::number(++j)
//                             });
//            m_gpsData.append({QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()),
//                              data.at(i)["dt"].toDateTime().toUTC().toString()
//                             });
            m_gpsData.append({QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()),
                              QString::number(data.at(i)["dt"].toDateTime().toMSecsSinceEpoch())
                             });
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


    struct ProcessingData {
        int rowIdx;
        int colIdx;
        QGeoPolygon polygon;
        QList<std::pair<QGeoCoordinate, QString>> gps;

    };

    auto writeProcessingDataToCsv = [](const std::string &fileName, const QList<ProcessingData> &processingData) {
        std::ofstream ofs(fileName, std::ios::out);
        if (!ofs.is_open()) {
            return;
        }

        for (const ProcessingData &processingDataItem : processingData) {
            ofs << processingDataItem.rowIdx << ',' << processingDataItem.colIdx << ',';


            for (int i = 0; i < processingDataItem.gps.size(); ++i) {
                if (i > 0) {
                    ofs << ';';
                }
                const std::string s = processingDataItem.gps.at(i).second.toStdString();
                ofs << s;
            }
            ofs << '\n';
        }
        ofs.close();
    };

//    auto  saveProcessingData = [](const QString &filePath, const QList<ProcessingData> &processingData) {
//        QFile file(filePath);
//        if (!file.open(QIODevice::WriteOnly)) {
//            qWarning() << "Cannot open file for writing:" << file.errorString();
//            return false;
//        }

//        QDataStream out(&file);
//        out.setVersion(QDataStream::Qt_6_4);
//        for (const auto &processingDataItem : processingData) {
//            out << processingDataItem.rowIdx << processingDataItem.colIdx;
//            for (const auto &gpsItem : processingDataItem.gps) {
//                out << gpsItem.second;
//            }
//        }
//        return true;
//    };



    QList<ProcessingData> processingData;
    processingData.reserve(paths.count());
    for (auto pathIdx{0}; pathIdx < paths.count(); ++pathIdx) {
        QGeoPolygon p;
        for (auto pointIdx{0}; pointIdx < paths.at(pathIdx).count(); ++pointIdx) {
            QGeoCoordinate c{paths.at(pathIdx).at(pointIdx).value<QGeoCoordinate>()};
            p.addCoordinate(c);
        }
        processingData.push_back(ProcessingData{
                    static_cast<int>(pathIdx / static_cast<std::size_t>(std::llround(std::sqrt(paths.count())))),   // row
                    static_cast<int>(pathIdx % static_cast<std::size_t>(std::llround(std::sqrt(paths.count())))),   // column
                    p
        });
    }

    for (auto &processingDataItem : processingData) {
        for (auto i{0}; i < m_gpsData.count(); ++i) {
            if (processingDataItem.polygon.contains(m_gpsData.at(i).first)) {
              processingDataItem.gps.emplace_back(m_gpsData.at(i));
            }
        }
    }

    writeProcessingDataToCsv("processing_data.csv", processingData);

    for (auto &pD : processingData) {
        qDebug() << pD.rowIdx << pD.colIdx << pD.gps.count() << pD.gps;
    }
//    saveProcessingData("processing_data.bin", processingData);

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

#include "markermodel.h"

#include <QRandomGenerator>

#include <QGeoPolygon>

MarkerModel::MarkerModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

int MarkerModel::rowCount(const QModelIndex &/*parent*/) const
{
        return static_cast<int>(m_markers.count());
}


QVariant MarkerModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_markers.size()) return QVariant();
    if (role == CoordinateRole) return QVariant::fromValue(m_markers.at(index.row()).first);
    return QVariant();
}

bool MarkerModel::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent, row, row + count - 1);
    for (auto i{0}; i < count; ++i) {
        m_markers.append(m_new_marker);
    }
    endInsertRows();
    return true;
}

bool MarkerModel::removeRows(int row, int count, const QModelIndex &parent)
{
    beginRemoveRows(parent, row, row + count - 1);
    for (auto i{0}; i < count; ++i) {
        m_markers.removeAt(row);
    }
    endRemoveRows();
    return true;
}

void MarkerModel::addMarker(const QGeoCoordinate &coord, const QString &name)
{
    m_new_marker = {coord, name};
    int row{rowCount()};
    insertRows(row, 1, QModelIndex());
}

bool MarkerModel::deleteMarker(int row, const QModelIndex &parent)
{
    return removeRows(row, 1, parent);
}

void MarkerModel::addData(QList<QVariantHash> data)
{
    m_gpsData.clear();
    for (auto i{0}, j{0}; i < data.count(); i += 1) {
        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
            m_gpsData.append({QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j)});
        }
    }
    auto nth{1};
    for (auto i{nth - 1}, j{0}; i < m_gpsData.count(); i += nth) {
            addMarker(QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j));
    }
//    auto nth{10};
//    for (auto i{nth - 1}, j{0}; i < data.count(); i += nth) {
//        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
//            addMarker(QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j));
//        }
//    }
}

void MarkerModel::deleteData() // TODO ???
{
    removeRows(0, rowCount(), QModelIndex());
}

void MarkerModel::processData(QGeoCoordinate topLeft, QGeoCoordinate bottomRight, QList<QVariantHash> data, int rows, int columns)
{
    struct Cell{
        QGeoCoordinate topLeft;
        QGeoCoordinate bottomRight;
    };
    QList<Cell> cells;

    auto hor{(bottomRight.latitude() - topLeft.latitude()) / columns};
    auto ver{(bottomRight.longitude() - topLeft.longitude()) / rows};

    for (auto r{0}; r < rows; ++r) {
        for (auto c{0}; c < columns; ++c) {
        cells.append({
                      QGeoCoordinate(topLeft.latitude() + c * hor, topLeft.longitude() + r * ver),
                      QGeoCoordinate(topLeft.latitude() + (c + 1) * hor, topLeft.longitude() + (r + 1) * ver)}
                     );
        }
    }

    qDebug() << rows << columns;





    QList<int> pointsInCells;
    pointsInCells.resize(cells.count());

    for (auto c{0}; c < cells.count(); ++c) {
        qDebug() << cells.at(c).topLeft.latitude();
        for (auto i{0}; i < data.count(); ++i) {
            if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {

                if (cells.at(c).bottomRight.latitude() <= data.at(i)["gps_lat"].value<double>() && data.at(i)["gps_lat"].value<double>() <= cells.at(c).topLeft.latitude()) {
                    if (cells.at(c).topLeft.longitude() <= data.at(i)["gps_lon"].value<double>() && data.at(i)["gps_lon"].value<double>() <= cells.at(c).bottomRight.longitude()) {
                        pointsInCells[c] += 1;
                    }
                }
            }
        }
    }

    for (const auto pIc : pointsInCells) {
        qDebug() << pIc;
    }
}

void MarkerModel::processDataTest(QGeoCoordinate topLeft, QGeoCoordinate bottomRight, int rows, int columns)
{
    struct Cell{
        QGeoCoordinate topLeft;
        QGeoCoordinate bottomRight;
    };
    QList<Cell> cells;

    auto hor{(bottomRight.latitude() - topLeft.latitude()) / columns};
    auto ver{(bottomRight.longitude() - topLeft.longitude()) / rows};


        for (auto c{0}; c < columns; ++c) {
            for (auto r{0}; r < rows; ++r) {
        cells.append({
                      QGeoCoordinate(topLeft.latitude() + c * hor, topLeft.longitude() + r * ver),
                      QGeoCoordinate(topLeft.latitude() + (c + 1) * hor, topLeft.longitude() + (r + 1) * ver)}
                     );
        }
    }

    QList<int> pointsInCells;
    pointsInCells.resize(cells.count());

    for (auto c{0}; c < cells.count(); ++c) {
        qDebug() << cells.at(c).topLeft.latitude() << cells.at(c).bottomRight.longitude();
        for (auto i{0}; i < m_markers.count(); ++i) {
                if (cells.at(c).bottomRight.latitude() <= m_markers.at(i).first.latitude() && m_markers.at(i).first.latitude() <= cells.at(c).topLeft.latitude()) {
                    if (cells.at(c).topLeft.longitude() <= m_markers.at(i).first.longitude() && m_markers.at(i).first.longitude() <= cells.at(c).bottomRight.longitude()) {
                        pointsInCells[c] += 1;
                    }
                }
            }
    }

    for (const auto pIc : pointsInCells) {
        qDebug() << pIc;
    }
}

void MarkerModel::processDataTest1(QList<QVariantList> paths)
{
    QList<QGeoPolygon> polygons(paths.count());
    for (auto pathIdx{0}; pathIdx < paths.count(); ++pathIdx) {
        for (auto pointIdx{0}; pointIdx < paths.at(pathIdx).count(); ++pointIdx) {
            QGeoCoordinate c{paths.at(pathIdx).at(pointIdx).value<QGeoCoordinate>()};
            polygons[pathIdx].addCoordinate(c);
        }
    }

//    auto distance{0.0};

//    for (auto i{0}; i < m_gpsData.count() - 1; ++i) {
//        auto c0{QGeoCoordinate{m_gpsData.at(i).first.latitude(), m_gpsData.at(i).first.longitude()}};
//        auto c1{QGeoCoordinate{m_gpsData.at(i + 1).first.latitude(), m_gpsData.at(i).first.longitude()}};
//        distance += c0.distanceTo(c1);
//    }

//    qDebug() << "Distance, m:" << distance;


    QList<int> pointsInPolygons(polygons.count());
    for (auto p{0}; p < polygons.count(); ++p) {
        for (auto i{0}; i < m_gpsData.count(); ++i) {
            if (polygons.at(p).contains(m_gpsData.at(i).first)) {
                pointsInPolygons[p] += 1;
            }
        }
    }

    for (auto i{0}; i < pointsInPolygons.count(); ++i) {
        qDebug() << i << pointsInPolygons.at(i);
    }
}

void MarkerModel::populateTest()
{
    for (auto i{0}; i < 10; ++i) {
        addMarker(QGeoCoordinate(56.76176699999999 + 0.0001 * QRandomGenerator::global()->bounded(-10, 10), 37.22133433333334 + 0.0001 * QRandomGenerator::global()->bounded(-10, 10)), QString::number(i));
    }

}

QHash<int, QByteArray> MarkerModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    // Add standard roles if needed (overriding roleNames replaces the default hash)
    roles[Qt::DisplayRole] = "display";
    roles[NameRole] = "name";
    roles[CoordinateRole] = "coordinate";
    return roles;
}

const QList<QPair<QGeoCoordinate, QString> > &MarkerModel::gpsData() const
{
    return m_gpsData;
}

const QList<QPair<QGeoCoordinate, QString> > &MarkerModel::markers() const
{
    return m_markers;
}

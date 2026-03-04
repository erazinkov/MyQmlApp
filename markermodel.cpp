#include "markermodel.h"

#include <QRandomGenerator>

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
    auto nth{1};
    for (auto i{nth - 1}, j{0}; i < data.count(); i += nth) {
        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
            addMarker(QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j));
        }
    }
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

const QList<QPair<QGeoCoordinate, QString> > &MarkerModel::markers() const
{
    return m_markers;
}

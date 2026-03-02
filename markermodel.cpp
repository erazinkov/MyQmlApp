#include "markermodel.h"


MarkerModel::MarkerModel(QObject *parent)
    : QAbstractListModel(parent)
{

}

int MarkerModel::rowCount(const QModelIndex &/*parent*/) const
{
        return static_cast<int>(m_markers.count());
}


//QVariant MarkerModel::data(const QModelIndex &index, int role) const
//{

//    if (!index.isValid())
//            return QVariant();

//        if (index.row() >= m_strings.size() || index.row() < 0)
//            return QVariant();

//        if (role == Qt::DisplayRole) {
//            return m_strings.at(index.row());
//        }
//        // You can add more roles here (e.g., Qt::UserRole + 1 for custom data)

//        return QVariant();
//}

//QVariant MarkerModel::headerData(int section, Qt::Orientation orientation, int role) const
//{
//    if (role != Qt::DisplayRole)
//        return QVariant();

//    if (orientation == Qt::Horizontal) {
//        return QStringLiteral("Column %1").arg(section);
//    } else {
//        return QStringLiteral("Row %1").arg(section + 1);
//    }
//}

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

void MarkerModel::addMarker(const QGeoCoordinate &coord, const QString &name)
{
    m_new_marker = {coord, name};
    int row{rowCount()};
    insertRows(row, 1, QModelIndex());
}

void MarkerModel::addData(QList<QVariantHash> data)
{
    for (auto i{0}, j{0}; i < data.count(); ++i) {
        if (data.at(i).contains("gps_lat") && data.at(i).contains("gps_lon")) {
            if (i == 0) {
                qDebug() << QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>());
            }
            addMarker(QGeoCoordinate(data.at(i)["gps_lat"].value<double>(), data.at(i)["gps_lon"].value<double>()), QString::number(++j));
        }
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

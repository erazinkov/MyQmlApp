#ifndef MARKERMODEL_H
#define MARKERMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include <QGeoCoordinate>

class MarkerModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum MarkerRoles {
        CoordinateRole = Qt::UserRole + 1,
        NameRole
    };
    MarkerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool insertRows(int row, int count, const QModelIndex &parent) override;
    void addMarker(const QGeoCoordinate &coord, const QString &name);
protected:
    QHash<int, QByteArray> roleNames() const override;
private:
    QList<QPair<QGeoCoordinate, QString>> m_markers;
    QPair<QGeoCoordinate, QString> m_new_marker;
//    QStringList m_strings;
};

#endif // MARKERMODEL_H

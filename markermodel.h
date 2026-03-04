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
    bool removeRows(int row, int count, const QModelIndex &parent) override;
    Q_INVOKABLE void addMarker(const QGeoCoordinate &coord, const QString &name);
    Q_INVOKABLE bool deleteMarker(int row, const QModelIndex &parent = QModelIndex());
    Q_INVOKABLE void addData(QList<QVariantHash> data);
    Q_INVOKABLE void deleteData();
    Q_INVOKABLE void processData(QGeoCoordinate topLeft, QGeoCoordinate bottomRight, QList<QVariantHash> data, int rows, int columns);

    Q_INVOKABLE void processDataTest(QGeoCoordinate topLeft, QGeoCoordinate bottomRight, int rows, int columns);

    Q_INVOKABLE void populateTest();

    void search(QGeoCoordinate coord) {

    }

    Q_INVOKABLE const QList<QPair<QGeoCoordinate, QString> > &markers() const;

protected:
    QHash<int, QByteArray> roleNames() const override;
private:
    QList<QPair<QGeoCoordinate, QString>> m_markers;
    QPair<QGeoCoordinate, QString> m_new_marker;
//    QStringList m_strings;
};

#endif // MARKERMODEL_H

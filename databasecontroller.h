#ifndef DATABASECONTROLLER_H
#define DATABASECONTROLLER_H

#include <QObject>
#include <QThread>
#include <QVariantHash>

#include <QGeoCoordinate>

#include "databaseworker.h"

class DatabaseController : public QObject
{
    Q_OBJECT
public:
    DatabaseController(QObject *parent = nullptr);
    ~DatabaseController() override;
signals:
    void connectionStateChanged(bool);
    void errorOccurred(const QString &);

    void operateConnectDatabase(const QString &connectionName,
                                const QString &driver,
                                const QString &hostName,
                                const QString &databaseName,
                                const QString &userName,
                                const QString &password);

    void operateDisconnectDatabase();

    void operateInsertData(int n,
                           const QString &dt,
                           const QString &fname,
                           double gps_lat,
                           double gps_lon,
                           const QString &gps_msg);

    void operateQuery(const QString &queryString);

    void operateSelectTables();
    void operateSelectForTable(const QString &queryString, const QStringList &keysAs);

    void operateSelectForTableWithCoordinate(const QGeoCoordinate &topLeft,
                                            const QGeoCoordinate &bottomRight,
                                            const QString &queryString,
                                            const QStringList &keysAs);

    void operateInsertCoordinate(const QVariant &data, const QDateTime &time);

    void connectDb(bool success, const QString &errorText, bool test = false);
    void disconnectDb();

    void insertData(const QString& str);

    void selectTables(QList<QVariant> data);
    void selectForTable(QList<QVariantHash> data);

    void selectForTableWithCoordinate(QList<QVariantHash> data);



public slots:
    void handleQuery(int timeAvg_min); // ??
    void handleResults(QList<QVariantHash> data); // ??
    void handleError(const QString &errorText);

private:
    QThread *m_thread;
    DatabaseWorker *m_worker;
};

#endif // DATABASECONTROLLER_H

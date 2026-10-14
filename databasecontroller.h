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
    void operateConnectDb(const QString &connectionName,
                              const QString &driver,
                              const QString &hostName,
                              const QString &databaseName,
                              const QString &userName,
                              const QString &password,
                              const QString &tableName, bool test = false);

    void operateDisconnectDb();

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
    void selectTables(QList<QVariant> data);
    void selectForTable(QList<QVariantHash> data);

    void selectForTableWithCoordinate(QList<QVariantHash> data);

    void errorOccured(const QString &errorText);

public slots:
    void handleQuery(int timeAvg_min); // ??
    void handleResults(QList<QVariantHash> data); // ??
    void handleError(const QString &errorText);

private:
    QThread *m_thread;
    DatabaseWorker *m_worker;
};

#endif // DATABASECONTROLLER_H

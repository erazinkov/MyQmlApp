#ifndef DATABASEWORKER_H
#define DATABASEWORKER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQueryModel>
#include <QSqlQuery>
#include <QGeoCoordinate>

class DatabaseWorker : public QObject
{
    Q_OBJECT
public:
    DatabaseWorker(QObject *parent = nullptr);
    ~DatabaseWorker() override;
public slots:
    void onConnectDatabase(const QString &connectionName,
                           const QString &driver,
                           const QString &hostName,
                           const QString &databaseName,
                           const QString &userName,
                           const QString &password);
    void onDisconnectDatabase();
    void handleSelectTables();
    void handleSelectForTable(const QString &queryString, const QStringList &keysAs);

    void handleSelectForTable1(const QString &queryString, const QStringList &keysAs);

    void handleSelectForTableWithCoordinate(const QGeoCoordinate &topLeft,
                                            const QGeoCoordinate &bottomRight,
                                            const QString &queryString,
                                            const QStringList &keysAs);

    void handleInsertCoordinate(const QVariant &data, const QDateTime &time);

signals:
    void connectDb(bool success, const QString &errorText, bool test = false);
    void disconnectDb();
    void connectionStateChanged(bool);
    void selectTables(QList<QVariant> queryResult);
    void selectForTable(QList<QVariantHash> queryResult);

    void selectForTableWithCoordinate(QList<QVariantHash> queryResult);

    void errorOccurred(const QString &errorText);

private:
    QString m_connectionName;

    bool checkTable(QSqlDatabase &db, const QString &tableName);
};

#endif // DATABASEWORKER_H

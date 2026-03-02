#ifndef DATABASEWORKER_H
#define DATABASEWORKER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQueryModel>
#include <QSqlQuery>

class DatabaseWorker : public QObject
{
    Q_OBJECT
public:
    DatabaseWorker(QObject *parent = nullptr);
    ~DatabaseWorker() override;
public slots:
    void handleConnectDb(const QString &connectionName,
                           const QString &driver,
                           const QString &hostName,
                           const QString &databaseName,
                           const QString &userName,
                           const QString &password,
                           const QString &tableName, bool test = false);
    void handleDisconnectDb();
    void handleSelectTables();
    void handleSelectForTable(const QString &tableName, const QStringList &keysAs);

    void handleSelectForTable1(const QString &tableName, const QStringList &keysAs);

signals:
    void connectDb(bool success, const QString &errorText, bool test = false);
    void disconnectDb();
    void selectTables(QList<QVariant> queryResult);
    void selectForTable(QList<QVariantHash> queryResult);
    void errorOccurred(const QString &errorText);

private:
    QString m_connectionName;

    bool checkTable(QSqlDatabase &db, const QString &tableName);
};

#endif // DATABASEWORKER_H

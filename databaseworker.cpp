#include "databaseworker.h"

#include <QDebug>
#include <QUuid>

#include <QSqlRecord>

#include <QTime>

DatabaseWorker::DatabaseWorker(QObject *parent) : QObject{parent}
{
}

DatabaseWorker::~DatabaseWorker()
{
    if (QSqlDatabase::contains(m_connectionName)) {
        QSqlDatabase::database(m_connectionName).close();
        QSqlDatabase::removeDatabase(m_connectionName);
    }

}

void DatabaseWorker::handleConnectDb(const QString &connectionName,
                               const QString &driver,
                               const QString &hostName,
                               const QString &databaseName,
                               const QString &userName,
                               const QString &password,
                               const QString &tableName,
                               bool test)
{
    {
        m_connectionName = connectionName + QUuid::createUuid().toString();
        QSqlDatabase db = QSqlDatabase::addDatabase(driver, m_connectionName);
        db.setHostName(hostName);
        db.setDatabaseName(databaseName);
        db.setUserName(userName);
        db.setPassword(password);

        auto success{db.open()};
        QString errorText{db.lastError().text()};
        if (success) {
            success = checkTable(db, tableName);
            if (!success) {
                errorText = QString("No \'%1\' table in database.").arg(tableName);
            }
        }
        emit connectDb(success, errorText, test);
    }
    if (test) {
        handleDisconnectDb();
    }
}

void DatabaseWorker::handleSelectTables()
{
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);
    QString queryString{QString("SELECT table_name "
                                "FROM information_schema.tables "
                                "WHERE table_schema = '%1'").arg(db.databaseName())};

    if (query.exec(queryString)) {
        QList<QVariant> queryResult;
        while (query.next()) {
            QVariant r{query.value(query.record().indexOf("table_name"))};
            queryResult.append(r);
        }
        emit selectTables(queryResult);
    } else {
        emit errorOccurred(query.lastError().text());
    }
}

void DatabaseWorker::handleSelectForTable(const QString &queryString, const QStringList &keysAs)
{
    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);
    if (query.exec(queryString)) {
        QList<QVariantHash> queryResult;
        while (query.next()) {
            QVariantHash row;
            for (auto i{0}; i < keysAs.count(); ++i) {
                auto fieldNumber{query.record().indexOf(keysAs.at(i))};
                if (fieldNumber != -1) {
                    row[keysAs.at(i)] = query.value(fieldNumber);
                }
            }
            queryResult.append(row);
        }
        emit selectForTable(queryResult);
    } else {
        emit errorOccurred(query.lastError().text());
    }
}

bool DatabaseWorker::checkTable(QSqlDatabase &db, const QString &tableName)
{
    QSqlQuery query(db);
    QString queryString{QString("SELECT table_name "
                                "FROM information_schema.tables "
                                "WHERE table_schema = '%1'").arg(db.databaseName())};

    if (query.exec(queryString)) {
        QStringList queryResult;
        while (query.next()) {
            QVariant r{query.value(query.record().indexOf("table_name"))};
            queryResult.append(r.toString());
        }
        return queryResult.contains(tableName);
    } else {
        emit errorOccurred(query.lastError().text());
        return false;
    }
}
void DatabaseWorker::handleDisconnectDb()
{
    if (QSqlDatabase::contains(m_connectionName)) {
        QSqlDatabase::database(m_connectionName).close();
        QSqlDatabase::removeDatabase(m_connectionName);
        emit disconnectDb();
    }
}

void DatabaseWorker::handleSelectForTable1(const QString &/*queryString*/, const QStringList &/*keysAs*/)
{
   const QStringList keys{
       "dt",
       "gps_lat",
       "gps_lon"
   };
    auto createQueryString = [&keys]()
    {
        const QString tableName{"curr_meas"};
        QString queryString;

        queryString.append(QString("SELECT "));
        QStringList sL_temp;
        for (auto i{0}; i < keys.count(); ++i) {
            sL_temp.append(QString("%1").arg(keys.at(i)));
        }
        queryString.append(sL_temp.join(", "));
        sL_temp.clear();
        queryString.append(QString(" FROM %1").arg(tableName));
        queryString.append(QString(" WHERE "));
        QDate d_0{2025, 06, 15};
        QDate d_1{2025, 06, 20};
        queryString.append(QString("DATE(%1) >= '%2' AND DATE(%1) <= '%3'").arg(keys.at(0)).arg(d_0.toString("yyyy-MM-dd")).arg(d_1.toString("yyyy-MM-dd")));
//        queryString.append(QString(" LIMIT 1000"));

        qDebug() << queryString;

        return queryString;
    };

    const QString queryString = createQueryString();

    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);
    if (query.exec(queryString)) {
        QList<QVariantHash> queryResult;
        while (query.next()) {
            QVariantHash row;
            for (auto i{0}; i < keys.count(); ++i) {
                auto fieldNumber{query.record().indexOf(keys.at(i))};
                if (fieldNumber != -1) {
                    row[keys.at(i)] = query.value(fieldNumber);
                }
            }
            queryResult.append(row);
        }
        emit selectForTable(queryResult);
    } else {
        emit errorOccurred(query.lastError().text());
    }
}

void DatabaseWorker::handleSelectForTableWithCoordinate(const QGeoCoordinate &topLeft,
                                                         const QGeoCoordinate &bottomRight,
                                                         const QString &/*queryString*/,
                                                         const QStringList &/*keysAs*/)
{
    const QStringList keys{
        "dt",
        "gps_lat",
        "gps_lon"
    };
     auto createQueryString = [&keys, &topLeft, &bottomRight]()
     {
         const QString tableName{"curr_meas"};
         QString queryString;

         queryString.append(QString("SELECT "));
         QStringList sL_temp;
         for (auto i{0}; i < keys.count(); ++i) {
             sL_temp.append(QString("%1").arg(keys.at(i)));
         }
         queryString.append(sL_temp.join(", "));
         sL_temp.clear();
         queryString.append(QString(" FROM %1").arg(tableName));
         queryString.append(QString(" WHERE "));
         QDate d_0{2025, 06, 15};
         QDate d_1{2025, 06, 20};

         QString tL_latitude = QString::number(topLeft.latitude(), 'g', 17);
         QString tL_longitude = QString::number(topLeft.longitude(), 'g', 17);
         QString bR_latitude = QString::number(bottomRight.latitude(), 'g', 17);
         QString bR_longitude = QString::number(bottomRight.longitude(), 'g', 17);

         queryString.append(QString("DATE(%1) >= '%2' AND DATE(%1) <= '%3'").arg("dt").arg(d_0.toString("yyyy-MM-dd")).arg(d_1.toString("yyyy-MM-dd")));
         queryString.append(QString(" AND %1 >= %2 AND %1 <= %3").arg("gps_lat").arg(bR_latitude).arg(tL_latitude));
         queryString.append(QString(" AND %1 >= %2 AND %1 <= %3").arg("gps_lon").arg(tL_longitude).arg(bR_longitude));
//         queryString.append(QString(" LIMIT 15000"));

         qDebug() << queryString;

         return queryString;
     };

     const QString queryString = createQueryString();

     QSqlDatabase db = QSqlDatabase::database(m_connectionName);
     QSqlQuery query(db);
     if (query.exec(queryString)) {
         QList<QVariantHash> queryResult;
         while (query.next()) {
             QVariantHash row;
             for (auto i{0}; i < keys.count(); ++i) {
                 auto fieldNumber{query.record().indexOf(keys.at(i))};
                 if (fieldNumber != -1) {
                     row[keys.at(i)] = query.value(fieldNumber);
                 }
             }
             queryResult.append(row);
         }
         emit selectForTableWithCoordinate(queryResult);
     } else {
         emit errorOccurred(query.lastError().text());
     }
}

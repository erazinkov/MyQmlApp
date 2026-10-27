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

void DatabaseWorker::onConnectDatabase(const QString &connectionName,
                               const QString &driver,
                               const QString &hostName,
                               const QString &databaseName,
                               const QString &userName,
                               const QString &password)
{
        m_connectionName = connectionName + QUuid::createUuid().toString();
        QSqlDatabase db = QSqlDatabase::addDatabase(driver, m_connectionName);
        db.setHostName(hostName);
        db.setDatabaseName(databaseName);
        db.setUserName(userName);
        db.setPassword(password);

        auto result{db.open()};
        auto lastError{db.lastError()};
        if (!result) {
            emit errorOccurred(lastError.text());
            return;
        }
        emit connectionStateChanged(result);

//        auto success{db.open()};
//        auto lastError{db.lastError()};
//        QString errorText{db.lastError().text()};
//        if (success) {
//            success = checkTable(db, tableName);
//            if (!success) {
//                errorText = QString("No \'%1\' table in database.").arg(tableName);
//            }
//        }
//        emit connectDb(success, errorText, test);
//        emit connectionStateChanged(success);

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
void DatabaseWorker::onDisconnectDatabase()
{
    auto result{QSqlDatabase::contains(m_connectionName)};
    if (result) {
        QSqlDatabase::database(m_connectionName).close();
        QSqlDatabase::removeDatabase(m_connectionName);
    }
    if (!result) {
        emit errorOccurred(QString("Can\'t disconnect \'%1\'").arg(m_connectionName));
        return;
    }
    emit connectionStateChanged(!result);
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
//        QDateTime d_0{QDate{2025, 06, 17}, QTime{13, 25, 0}};
//        QDateTime d_1{QDate{2025, 06, 17}, QTime{13, 44, 0}};
//        QDateTime d_0{QDate{2025, 06, 18}, QTime{19, 02, 0}};
//        QDateTime d_1{QDate{2025, 06, 18}, QTime{19, 19, 0}};
//        QDateTime d_0{QDate{2025, 06, 18}, QTime{19, 00, 0}};
//        QDateTime d_1{QDate{2025, 06, 18}, QTime{19, 20, 0}};
        QDateTime d_0{QDate{2025, 06, 17}, QTime{10, 00, 0}};
        QDateTime d_1{QDate{2025, 06, 18}, QTime{19, 30, 0}};
        queryString.append(QString("%1 >= '%2' AND %1 <= '%3'").arg(keys.at(0)).arg(d_0.toString("yyyy-MM-dd HH:mm:ss")).arg(d_1.toString("yyyy-MM-dd HH:mm:ss")));


//        QDate d_0{2025, 06, 15};
//        QDate d_1{2025, 06, 21};
//        QDate d_0{2025, 06, 18};
//        QDate d_1{2025, 06, 18};
//        queryString.append(QString("DATE(%1) >= '%2' AND DATE(%1) <= '%3'").arg(keys.at(0)).arg(d_0.toString("yyyy-MM-dd")).arg(d_1.toString("yyyy-MM-dd")));
//        queryString.append(QString(" LIMIT 1000"));

        qDebug() << queryString;

        return queryString;
    };

    const QString queryString = createQueryString();

    bool is = false;
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
            if (!is) {
                qDebug() << row;
                is = true;
            }
        }
        emit selectForTable(queryResult);
    } else {
        emit errorOccurred(query.lastError().text());
    }
}

void DatabaseWorker::onInsertData(int n,
                                  const QString &dt,
                                  const QString &fname,
                                  double gps_lat,
                                  double gps_lon,
                                  const QString &gps_msg)
{
    const QStringList keys{
        "n",
        "dt",
        "fname",
        "gps_lat",
        "gps_lon",
        "gps_msg"
    };
    QStringList values;
    values.push_back(QString::number(n));
    values.push_back("'" + dt + "'");
    values.push_back("'" + fname + "'");
    values.push_back(QString::number(gps_lat, 'g', 17));
    values.push_back(QString::number(gps_lon, 'g', 17));
    values.push_back("'" + gps_msg + "'");
    auto createQueryString = [&keys, &values]()
    {
        const QString tableName{"curr_meas"};
        QString queryString;

        queryString.append(QString("INSERT "));
        queryString.append(QString("INTO %1").arg(tableName));
        queryString.append(QString(" ("));
        QStringList sL_temp;
        for (auto i{0}; i < keys.count(); ++i) {
            sL_temp.append(QString("%1").arg(keys.at(i)));
        }
        queryString.append(sL_temp.join(", "));
        sL_temp.clear();
        queryString.append(QString(")"));
        queryString.append(" VALUES");
        queryString.append(QString(" ("));
        for (auto i{0}; i < values.count(); ++i) {
            sL_temp.append(QString("%1").arg(values.at(i)));
        }
        queryString.append(sL_temp.join(", "));
        queryString.append(QString(")"));
        sL_temp.clear();

        qDebug() << queryString;

        return queryString;
    };
    const QString queryString = createQueryString();

    QSqlDatabase db = QSqlDatabase::database(m_connectionName);
    QSqlQuery query(db);
    if (query.exec(queryString)) {
        emit insertData(QString("INSERT successful | %1 | %2 | %3").arg(values.at(1),
                                                     QString::number(values.at(3).toDouble(), 'g', 9),
                                                     QString::number(values.at(4).toDouble(), 'g', 9))
                        );
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

void DatabaseWorker::handleInsertCoordinate(const QVariant &data, const QDateTime &time)
{
    QGeoCoordinate c;

    if (data.canConvert<QGeoCoordinate>()) {
        c = data.value<QGeoCoordinate>();
    } else if (data.canConvert<QVariantMap>()) {
        QVariantMap m = data.toMap();
        c = QGeoCoordinate(
            m.value("latitude").toDouble(),
            m.value("longitude").toDouble(),
            m.value("altitude", 0.0).toDouble()
        );
    } else {
        qWarning() << "Invalid coordinate!";
        return;
    }
    qDebug() << c << time;

}

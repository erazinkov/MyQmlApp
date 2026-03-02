#include "databasecontroller.h"

#include <QSqlQueryModel>

DatabaseController::DatabaseController(QObject *parent) : QObject{parent}
{
    m_thread = new QThread(this);
    m_worker = new DatabaseWorker;
    m_worker->moveToThread(m_thread);
    // Connect signals from controller to worker slots (queued connection by default)
    connect(this, &DatabaseController::operateConnectDb, m_worker, &DatabaseWorker::handleConnectDb);
    connect(this, &DatabaseController::operateDisconnectDb, m_worker, &DatabaseWorker::handleDisconnectDb);

    connect(this, &DatabaseController::operateSelectTables, m_worker, &DatabaseWorker::handleSelectTables);
    connect(this, &DatabaseController::operateSelectForTable, m_worker, &DatabaseWorker::handleSelectForTable1);

    connect(m_worker, &DatabaseWorker::connectDb, this, &DatabaseController::connectDb);
    connect(m_worker, &DatabaseWorker::disconnectDb, this, &DatabaseController::disconnectDb);
    connect(m_worker, &DatabaseWorker::selectTables, this, &DatabaseController::selectTables);
    connect(m_worker, &DatabaseWorker::selectForTable, this, &DatabaseController::selectForTable);

    connect(m_worker, &DatabaseWorker::errorOccurred, this, &DatabaseController::errorOccured);

    // Ensure thread and worker cleanup
    connect(m_thread, &QThread::finished, m_worker, &QObject::deleteLater);

    m_thread->start();
}

DatabaseController::~DatabaseController()
{
    m_thread->quit();
    m_thread->wait();
}

void DatabaseController::handleQuery(int timeAvg_min)
{
    QString queryString{QString("SELECT "
                                  "FROM_UNIXTIME(FLOOR(UNIX_TIMESTAMP(_date) / %1) * %1) AS date_avg, "
                                  "AVG(Al) AS al_avg, "
                                  "AVG(Ca) AS ca_avg, "
                                  "AVG(Fe) AS fe_avg, "
                                  "AVG(Si) AS si_avg "
                                  "FROM "
                                  "result "
                                  "WHERE Al > 0.01 AND Ca > 0.01 AND Fe > 0.01 AND Si > 0.01"
//                                  "WHERE _date < '2022-05-19 00:00:00'"
                                  "GROUP BY "
                                  "date_avg "
                                  "ORDER BY "
                                  "date_avg "
                                  "LIMIT 1500").arg(timeAvg_min * 60)};
    emit operateQuery(queryString);
}

void DatabaseController::handleResults(QList<QVariantHash> data)
{
}

void DatabaseController::handleError(const QString &errorText)
{
    qDebug() << errorText;
}


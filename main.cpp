#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <QStringLiteral>
#include <QRandomGenerator>

#include <QQmlContext>

#include "markermodel.h"

#include "databasecontroller.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "MyQmlApp_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    MarkerModel markerModel;

    DatabaseController dbController;

//    dbController.operateSelectForTable();


    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/MyQmlApp/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
//    engine.rootContext()->setContextProperty("markerModel", &markerModel);
    qmlRegisterType<MarkerModel>("markerModel", 1, 0, "MarkerModel");
    qmlRegisterType<DatabaseController>("dbController", 1, 0, "DatabaseController");
    engine.load(url);




//    for (auto i{0}; i < 1200; ++i) {
//        markerModel.addMarker(QGeoCoordinate(56.76169483333333 + 0.0001 * QRandomGenerator::global()->bounded(-10, 10), 37.221216999999996 + 0.0001 * QRandomGenerator::global()->bounded(-10, 10)), QString::number(i));
//    }


    return app.exec();
}

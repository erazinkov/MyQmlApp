#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <QStringLiteral>

#include <QQmlContext>

#include "markermodel.h"

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
    markerModel.addMarker(QGeoCoordinate(56.76169483333333, 37.221216999999996), "0");
    qDebug() << markerModel.rowCount();

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/MyQmlApp/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.rootContext()->setContextProperty("markerModel", &markerModel);
    engine.load(url);

    return app.exec();
}

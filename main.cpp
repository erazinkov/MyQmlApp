#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>
#include <QStringLiteral>


#include <QQmlContext>

 #include "markermodel.h"

 #include "databasecontroller.h"

//#include "processing.h"

 #include "processingcontroller.h"

using namespace Qt::StringLiterals;

class Test {
    Test();
    int v;
};

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
     ProcessingController pController;

//    Processing processing;

//    dbController.operateSelectForTable();

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/MyQmlApp/main.qml"_s);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    // qmlRegisterType<Test>("test", 1, 0, "Test");
     qmlRegisterType<MarkerModel>("markerModel", 1, 0, "MarkerModel");
     qmlRegisterType<DatabaseController>("dbController", 1, 0, "DatabaseController");
//     qmlRegisterType<ProcessingController>("pController", 1, 0, "ProcessingController");
     engine.rootContext()->setContextProperty("pController", &pController);
    engine.load(url);


    return app.exec();
}

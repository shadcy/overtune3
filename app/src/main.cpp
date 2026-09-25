#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QFont>
#include "FilterEngine.h"
#include "SimulationModel.h"
#include "ExportModel.h"
#include "ThemeManager.h"

int main(int argc, char* argv[]) {
    // Avoid GTK theme crash on Ubuntu Wayland/GNOME
    qputenv("QT_QPA_PLATFORMTHEME", "generic");

    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication::setApplicationName("Overtune 3");
    QGuiApplication::setOrganizationName("Overtune");
    QGuiApplication::setApplicationVersion("3.0.0");

    QGuiApplication app(argc, argv);
    app.setFont(QFont(QStringLiteral("Inter")));

    // Instantiate backend objects
    FilterEngine    engine;
    SimulationModel simulation;
    ExportModel     exportModel;
    ThemeManager    theme;

    QQmlApplicationEngine qml;

    // Expose C++ objects to QML
    qml.rootContext()->setContextProperty("filterEngine",  &engine);
    qml.rootContext()->setContextProperty("simulation",    &simulation);
    qml.rootContext()->setContextProperty("exportModel",   &exportModel);
    qml.rootContext()->setContextProperty("theme",         &theme);

    const QUrl url(u"qrc:/FilterDesigner/qml/Main.qml"_qs);
    QObject::connect(&qml, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject* obj, const QUrl& objUrl) {
        if (!obj && url == objUrl) QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    qml.load(url);

    return app.exec();
}

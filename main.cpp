#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>
#include "mpris.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Find HDMI-A-1 (2560-wide primary); fall back to primaryScreen
    QScreen *target = nullptr;
    for (QScreen *s : app.screens()) {
        qDebug() << "Screen:" << s->name() << s->geometry();
        if (s->name() == "HDMI-A-1" || s->size().width() == 2560) {
            target = s;
        }
    }
    if (!target) target = app.primaryScreen();

    MprisController mpris;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("targetScreen", target);
    engine.rootContext()->setContextProperty("mpris", &mpris);
    engine.load(QUrl::fromLocalFile(
        QString(SOURCE_DIR) + "/notch-window.qml"));

    return app.exec();
}

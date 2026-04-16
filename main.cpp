#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <LayerShellQt/Shell>
#include <LayerShellQt/Window>

int main(int argc, char *argv[])
{
    // Must be called before QGuiApplication
    LayerShellQt::Shell::useLayerShell();

    QGuiApplication app(argc, argv);

    // Find the target screen (HDMI-A-1, the 2560-wide primary)
    QScreen *target = nullptr;
    for (QScreen *s : app.screens()) {
        qDebug() << "Screen:" << s->name() << s->size() << s->geometry();
        if (s->name() == "HDMI-A-1" || s->size().width() == 2560) {
            target = s;
        }
    }
    if (!target) target = app.primaryScreen();

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("targetScreen", target);
    engine.load(QUrl::fromLocalFile(
        QString(SOURCE_DIR) + "/notch-window.qml"));

    return app.exec();
}

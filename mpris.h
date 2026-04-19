#pragma once
#include <QObject>
#include <QTimer>
#include <QString>
#include <QStringList>
#include <QVariantMap>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusArgument>

class MprisController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title    READ title    NOTIFY metadataChanged)
    Q_PROPERTY(QString artist   READ artist   NOTIFY metadataChanged)
    Q_PROPERTY(QString artUrl   READ artUrl   NOTIFY metadataChanged)
    Q_PROPERTY(bool    playing  READ playing  NOTIFY playbackStatusChanged)
    Q_PROPERTY(bool    hasPlayer READ hasPlayer NOTIFY hasPlayerChanged)

public:
    explicit MprisController(QObject *parent = nullptr) : QObject(parent)
    {
        m_timer = new QTimer(this);
        m_timer->setInterval(2000);
        connect(m_timer, &QTimer::timeout, this, &MprisController::refresh);
        m_timer->start();
        refresh();
    }

    QString title()     const { return m_title; }
    QString artist()    const { return m_artist; }
    QString artUrl()    const { return m_artUrl; }
    bool    playing()   const { return m_playing; }
    bool    hasPlayer() const { return !m_service.isEmpty(); }

    Q_INVOKABLE void playPause() { call("PlayPause"); }
    Q_INVOKABLE void next()      { call("Next"); }
    Q_INVOKABLE void previous()  { call("Previous"); }

signals:
    void metadataChanged();
    void playbackStatusChanged();
    void hasPlayerChanged();

private:
    void refresh()
    {
        // Find first active MPRIS2 player on the session bus
        QDBusInterface dbus("org.freedesktop.DBus", "/",
                            "org.freedesktop.DBus",
                            QDBusConnection::sessionBus());
        QDBusReply<QStringList> names = dbus.call("ListNames");
        if (!names.isValid()) return;

        QString found;
        for (const QString &n : names.value())
            if (n.startsWith("org.mpris.MediaPlayer2.")) { found = n; break; }

        bool had = hasPlayer();
        m_service = found;
        if (had != hasPlayer()) emit hasPlayerChanged();
        if (m_service.isEmpty()) return;

        QDBusInterface props(m_service, "/org/mpris/MediaPlayer2",
                             "org.freedesktop.DBus.Properties",
                             QDBusConnection::sessionBus());

        // Metadata
        QDBusReply<QVariant> meta = props.call("Get", "org.mpris.MediaPlayer2.Player", "Metadata");
        if (meta.isValid()) {
            QVariantMap map = qdbus_cast<QVariantMap>(meta.value());
            QString t = map.value("xesam:title").toString();
            QStringList al = map.value("xesam:artist").toStringList();
            QString a = al.join(", ");
            QString art = map.value("mpris:artUrl").toString();
            if (t != m_title || a != m_artist || art != m_artUrl) {
                m_title = t; m_artist = a; m_artUrl = art;
                emit metadataChanged();
            }
        }

        // Playback status
        QDBusReply<QVariant> status = props.call("Get", "org.mpris.MediaPlayer2.Player", "PlaybackStatus");
        if (status.isValid()) {
            bool p = status.value().toString() == "Playing";
            if (p != m_playing) { m_playing = p; emit playbackStatusChanged(); }
        }
    }

    void call(const QString &method)
    {
        if (m_service.isEmpty()) return;
        QDBusInterface player(m_service, "/org/mpris/MediaPlayer2",
                              "org.mpris.MediaPlayer2.Player",
                              QDBusConnection::sessionBus());
        player.call(method);
        // Refresh immediately so play/pause icon updates fast
        QTimer::singleShot(150, this, &MprisController::refresh);
    }

    QString  m_service;
    QString  m_title;
    QString  m_artist;
    QString  m_artUrl;
    bool     m_playing = false;
    QTimer  *m_timer;
};

import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import org.kde.layershell 1.0 as LayerShell

Window {
    id: win

    flags: Qt.FramelessWindowHint
    color: "transparent"
    visible: true

    readonly property int notchWidth:    220
    readonly property int collapsedHeight: 32
    readonly property int expandedHeight:  96
    readonly property int cornerRadius:   10

    screen: targetScreen

    width:  notchWidth
    height: collapsedHeight

    Behavior on height {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }

    LayerShell.Window.anchors:       LayerShell.Window.AnchorTop
                                   | LayerShell.Window.AnchorLeft
                                   | LayerShell.Window.AnchorRight
    LayerShell.Window.layer:         LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: 0
    LayerShell.Window.scope:         "notch"
    LayerShell.Window.screen:        targetScreen

    // ── Hover detection over the notch shape only ────────────────────────────
    MouseArea {
        id: hoverArea
        x: (parent.width - win.notchWidth) / 2
        y: 0
        width:  win.notchWidth
        height: win.height
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onEntered: win.height = win.expandedHeight
        onExited:  win.height = win.collapsedHeight
    }

    // ── Notch shape ───────────────────────────────────────────────────────────
    Canvas {
        id: canvas
        width:  win.notchWidth
        height: win.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        onWidthChanged:  requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            var r = win.cornerRadius
            var w = width
            var h = height

            ctx.clearRect(0, 0, w, h)
            ctx.fillStyle = "#000000"
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(w, 0)
            ctx.lineTo(w, h - r)
            ctx.arcTo(w, h, w - r, h, r)
            ctx.lineTo(r, h)
            ctx.arcTo(0, h, 0, h - r, r)
            ctx.lineTo(0, 0)
            ctx.closePath()
            ctx.fill()
        }
    }

    // ── Camera dot (always visible in top section) ────────────────────────────
    Rectangle {
        anchors.horizontalCenter: canvas.horizontalCenter
        anchors.top: canvas.top
        anchors.topMargin: (win.collapsedHeight - height) / 2
        width: 7; height: 7; radius: 4
        color: "#1c1c1e"
        border.color: "#3a3a3c"
        border.width: 1
        Rectangle {
            anchors.centerIn: parent
            width: 3; height: 3; radius: 2
            color: "#2c2c2e"
        }
    }

    // ── Media controls (fade in when expanded) ────────────────────────────────
    Item {
        id: mediaPanel
        anchors.horizontalCenter: canvas.horizontalCenter
        anchors.bottom: canvas.bottom
        anchors.bottomMargin: 10
        width: win.notchWidth - 20
        height: win.expandedHeight - win.collapsedHeight - 10

        opacity: Math.max(0, (win.height - win.collapsedHeight) /
                              (win.expandedHeight - win.collapsedHeight) * 2 - 1)
        visible: opacity > 0

        ColumnLayout {
            anchors.fill: parent
            spacing: 4

            // Track title
            Text {
                Layout.fillWidth: true
                text: mpris.hasPlayer ? (mpris.title || "Unknown track") : "Nothing playing"
                color: "white"
                font.pixelSize: 11
                font.family: "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            // Artist
            Text {
                Layout.fillWidth: true
                visible: mpris.hasPlayer && mpris.artist !== ""
                text: mpris.artist
                color: "#888888"
                font.pixelSize: 10
                font.family: "Helvetica"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            // Prev / Play-Pause / Next
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                Text {
                    text: "⏮"
                    color: mpris.hasPlayer ? "white" : "#444"
                    font.pixelSize: 16
                    MouseArea {
                        anchors.fill: parent
                        enabled: mpris.hasPlayer
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpris.previous()
                    }
                }

                Text {
                    text: mpris.playing ? "⏸" : "▶"
                    color: mpris.hasPlayer ? "white" : "#444"
                    font.pixelSize: 16
                    MouseArea {
                        anchors.fill: parent
                        enabled: mpris.hasPlayer
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpris.playPause()
                    }
                }

                Text {
                    text: "⏭"
                    color: mpris.hasPlayer ? "white" : "#444"
                    font.pixelSize: 16
                    MouseArea {
                        anchors.fill: parent
                        enabled: mpris.hasPlayer
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mpris.next()
                    }
                }
            }
        }
    }
}

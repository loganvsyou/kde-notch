import QtQuick
import QtQuick.Window
import org.kde.layershell 1.0 as LayerShell

Window {
    id: win

    flags: Qt.FramelessWindowHint
    color: "transparent"
    visible: true

    readonly property int notchWidth:   220
    readonly property int notchHeight:  32
    readonly property int cornerRadius: 10

    width:  notchWidth
    height: notchHeight

    screen: targetScreen

    LayerShell.Window.anchors:       LayerShell.Window.AnchorTop
                                   | LayerShell.Window.AnchorLeft
                                   | LayerShell.Window.AnchorRight
    LayerShell.Window.layer:         LayerShell.Window.LayerOverlay
    LayerShell.Window.exclusionZone: 0
    LayerShell.Window.scope:         "notch"
    LayerShell.Window.screen:        targetScreen

    Canvas {
        id: canvas
        width:  win.notchWidth
        height: win.notchHeight
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
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

    Rectangle {
        anchors.centerIn: canvas
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
}

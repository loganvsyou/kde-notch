import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    readonly property int notchWidth:   Plasmoid.configuration.notchWidth
    readonly property int notchHeight:  Plasmoid.configuration.notchHeight
    readonly property int cornerRadius: Plasmoid.configuration.cornerRadius
    readonly property bool showCameraDot: Plasmoid.configuration.showCameraDot
    readonly property color notchColor: Plasmoid.configuration.notchColor

    // Clock string updated every second
    property string clockText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date()
            root.clockText = Qt.formatTime(d, "hh:mm") +
                             "  ·  " +
                             Qt.formatDate(d, "ddd d MMM")
        }
    }

    fullRepresentation: Item {
        implicitWidth:  root.notchWidth
        implicitHeight: root.notchHeight
        Layout.minimumWidth:  root.notchWidth
        Layout.preferredWidth: root.notchWidth
        Layout.maximumWidth:  root.notchWidth
        Layout.fillHeight: true

        // Notch shape: square top, rounded bottom corners only
        Canvas {
            id: canvas
            anchors.fill: parent

            onWidthChanged:  requestPaint()
            onHeightChanged: requestPaint()
            Component.onCompleted: requestPaint()

            Connections {
                target: root
                function onNotchColorChanged()  { canvas.requestPaint() }
                function onCornerRadiusChanged() { canvas.requestPaint() }
            }

            onPaint: {
                var ctx = getContext("2d")
                var r = root.cornerRadius
                var w = width
                var h = height

                ctx.clearRect(0, 0, w, h)
                ctx.fillStyle = root.notchColor.toString()

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

        // Camera dot centred in the notch
        Rectangle {
            visible: root.showCameraDot
            anchors.centerIn: parent
            width: 7
            height: 7
            radius: 4
            color: "#1c1c1e"
            border.color: "#3a3a3c"
            border.width: 1

            Rectangle {
                anchors.centerIn: parent
                width: 3
                height: 3
                radius: 2
                color: "#2c2c2e"
            }
        }

        // Hover → show time/date tooltip
        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }

        QQC2.ToolTip {
            visible: hoverArea.containsMouse
            delay: 0
            text: root.clockText
        }
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_notchWidth:    widthSpinBox.value
    property alias cfg_notchHeight:   heightSpinBox.value
    property alias cfg_cornerRadius:  radiusSpinBox.value
    property alias cfg_showCameraDot: cameraDotCheck.checked
    property string cfg_notchColor

    // ── Size ─────────────────────────────────────────────────────────────────
    QQC2.SpinBox {
        id: widthSpinBox
        Kirigami.FormData.label: "Notch width:"
        from: 80
        to: 800
        stepSize: 10
    }

    QQC2.SpinBox {
        id: heightSpinBox
        Kirigami.FormData.label: "Notch height:"
        from: 16
        to: 80
        stepSize: 2
    }

    QQC2.SpinBox {
        id: radiusSpinBox
        Kirigami.FormData.label: "Corner radius:"
        from: 0
        to: 40
    }

    // ── Appearance ────────────────────────────────────────────────────────────
    QQC2.TextField {
        id: colorField
        Kirigami.FormData.label: "Color (hex):"
        text: cfg_notchColor
        onTextChanged: {
            if (/^#[0-9a-fA-F]{6}$/.test(text)) {
                cfg_notchColor = text
            }
        }
        maximumLength: 7
        placeholderText: "#000000"
    }

    // ── Camera dot ───────────────────────────────────────────────────────────
    QQC2.CheckBox {
        id: cameraDotCheck
        Kirigami.FormData.label: "Show camera dot:"
        text: "Pulse green when camera is in use"
    }
}

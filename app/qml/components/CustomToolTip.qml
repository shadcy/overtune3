import QtQuick
import QtQuick.Controls as QQC

// CustomToolTip.qml — Global premium tooltip component styled identically to the Sidebar
QQC.ToolTip {
    id: control

    property string shortcut: ""

    delay: 350
    timeout: 4500
    topPadding: 5
    bottomPadding: 5
    leftPadding: 9
    rightPadding: 9
    closePolicy: QQC.Popup.CloseOnEscape | QQC.Popup.CloseOnPressOutsideParent | QQC.Popup.CloseOnReleaseOutsideParent

    // Extract shortcut from text if not provided explicitly (e.g. "(Ctrl+0)", "(Ctrl+T)", "(+)", "(-)")
    readonly property string parsedShortcut: {
        if (control.shortcut && control.shortcut.length > 0)
            return control.shortcut
        const raw = control.text || ""
        const match = raw.match(/\((Ctrl\+[A-Za-z0-9]|Alt\+[A-Za-z0-9]|F[1-9]|F1[0-2]|\+|\u2212|-)\)$/)
        return match ? match[1] : ""
    }

    readonly property string displayText: {
        if (control.shortcut && control.shortcut.length > 0)
            return control.text
        const raw = control.text || ""
        const match = raw.match(/^(.*?)\s*\((Ctrl\+[A-Za-z0-9]|Alt\+[A-Za-z0-9]|F[1-9]|F1[0-2]|\+|\u2212|-)\)$/)
        return match ? match[1].trim() : raw
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 130; easing.type: Easing.OutQuad }
        NumberAnimation { property: "scale"; from: 0.94; to: 1.0; duration: 130; easing.type: Easing.OutQuad }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100; easing.type: Easing.InQuad }
    }

    contentItem: Row {
        spacing: 8

        Text {
            text: control.displayText
            color: (typeof theme !== "undefined" && theme.isDark) ? "#FFFFFF" : "#1D1D1F"
            font.family: (typeof theme !== "undefined" && theme.headlineFont) ? theme.headlineFont : "Stack Sans Headline"
            font.pixelSize: 11
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            visible: control.parsedShortcut !== ""
            width: scLabel.implicitWidth + 8
            height: 18
            radius: 4
            color: (typeof theme !== "undefined" && theme.isDark) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: scLabel
                anchors.centerIn: parent
                text: control.parsedShortcut
                color: (typeof theme !== "undefined" && theme.isDark) ? "#A0A0A5" : "#6E6E73"
                font.family: (typeof theme !== "undefined" && theme.headlineFont) ? theme.headlineFont : "Stack Sans Headline"
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }
    }

    background: Rectangle {
        color: (typeof theme !== "undefined" && theme.isDark) ? "#222225" : "#FFFFFF"
        border.color: (typeof theme !== "undefined" && theme.isDark) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
        border.width: 1
        radius: 6
    }
}

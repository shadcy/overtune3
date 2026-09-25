import QtQuick
import QtQuick.Controls

// StyledButton.qml — overflow-safe button with Inter
Button {
    id: root
    implicitHeight: 30
    implicitWidth: 100
    font.family: "Stack Sans Headline"
    font.pixelSize: 13
    padding: 8
    leftPadding: 10
    rightPadding: 10
    clip: true

    property bool primary: true

    background: Rectangle {
        radius: 8
        color: {
            if (!root.enabled)
                return root.primary ? "#0A84FF55" : theme.surface
            if (root.primary)
                return root.pressed ? "#0070E0" : (hov.hovered ? "#1890FF" : "#0A84FF")
            return root.pressed || hov.hovered ? theme.surfaceHigh : theme.surface
        }
        border.color: root.primary ? "transparent" : theme.borderColor
        border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: root.primary ? "#FFFFFF" : theme.primaryText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: root.enabled ? 1 : 0.5
    }

    HoverHandler {
        id: hov
        cursorShape: Qt.PointingHandCursor
    }
}

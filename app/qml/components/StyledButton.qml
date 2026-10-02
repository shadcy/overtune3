import QtQuick
import QtQuick.Controls

// StyledButton.qml — Squircle-style button, consistent with the What's New "Got it" design
Button {
    id: root
    implicitHeight: 30
    implicitWidth: Math.max(90, (contentItem ? contentItem.implicitWidth : 0) + leftPadding + rightPadding + 4)
    font.family: "Stack Sans Headline"
    font.pixelSize: 12
    font.weight: Font.DemiBold
    padding: 0
    leftPadding: 14
    rightPadding: 14
    clip: true

    // true  → blue filled  (#0A84FF family)
    // false → ghost        (border only, theme-adaptive)
    property bool primary: true
    property bool danger: false

    // Subtle press-down scale
    scale: root.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 80; easing.type: Easing.OutQuad } }

    background: Rectangle {
        radius: 7   // squircle radius — matches "Got it" button exactly
        color: {
            if (root.danger)
                return root.pressed ? Qt.darker(theme.danger, 1.2)
                     : hov.hovered ? Qt.lighter(theme.danger, 1.08)
                     : theme.danger
            if (!root.enabled)
                return root.primary ? "#0A84FF44" : "transparent"
            if (root.primary)
                return root.pressed ? "#0061C3"
                     : hov.hovered  ? "#0071E3"
                     :                "#0A84FF"
            // Ghost (secondary)
            return root.pressed ? (theme.isDark ? "#2A2A36" : "#E8E8EE")
                 : hov.hovered  ? (theme.isDark ? "#1E1E28" : "#F0F0F6")
                 :                "transparent"
        }
        border.color: {
            if (root.danger)
                return "transparent"
            if (!root.enabled)
                return root.primary ? "transparent" : theme.borderColor
            return root.primary ? "transparent" : theme.borderColor
        }
        border.width: root.primary ? 0 : 1
        Behavior on color { ColorAnimation { duration: 110 } }
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: {
            if (!root.enabled)
                return root.primary ? "#FFFFFF88" : theme.secondaryText
            return (root.primary || root.danger) ? "#FFFFFF" : theme.primaryText
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment:   Text.AlignVCenter
        elide: Text.ElideRight
        Behavior on color { ColorAnimation { duration: 110 } }
    }

    HoverHandler {
        id: hov
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}

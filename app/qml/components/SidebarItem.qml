import QtQuick
import QtQuick.Controls

// SidebarItem.qml — VS Code activity bar item with smooth interactive micro-animations
Item {
    id: root
    width: parent ? parent.width : 48
    height: 48

    property bool   selected: false
    property string text: ""
    property string icon: "tools"
    property string shortcut: ""
    signal clicked()

    // ── Hover / Press Background ──────────────────────────────────────────────
    Rectangle {
        id: hoverPill
        anchors.fill: parent
        anchors.margins: 4
        radius: 8
        color: {
            if (tapHandler.pressed)
                return theme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.09)
            if (hov.hovered && !selected)
                return theme.isDark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.045)
            if (hov.hovered && selected)
                return theme.isDark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.03)
            return "transparent"
        }
        border.color: (hov.hovered && !selected) ?
            (theme.isDark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.04)) : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.OutQuad } }
    }

    // ── Keyboard Focus Ring ───────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: 9
        color: "transparent"
        border.color: theme.accent
        border.width: 1.5
        opacity: root.activeFocus ? 0.9 : 0
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }

    // ── Animated Icon Container with Tactile Physics ──────────────────────────
    Item {
        id: iconWrapper
        anchors.fill: parent

        scale: {
            if (tapHandler.pressed) return 0.88
            if (hov.hovered) return 1.08
            if (selected) return 1.02
            return 1.0
        }

        Behavior on scale {
            NumberAnimation {
                duration: tapHandler.pressed ? 75 : 180
                easing.type: tapHandler.pressed ? Easing.OutQuad : Easing.OutBack
                easing.overshoot: 1.35
            }
        }

        Codicon {
            id: glyph
            anchors.centerIn: parent
            icon: root.icon
            iconSize: 21
            iconColor: {
                if (selected)
                    return theme.isDark ? "#FFFFFF" : theme.accent
                if (hov.hovered)
                    return theme.isDark ? "#ECECED" : "#1D1D1F"
                return theme.isDark ? "#8A8A8E" : "#6E6E73"
            }
            Behavior on iconColor {
                ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            rotation: (root.icon === "settings-gear" && (hov.hovered || selected)) ? (selected ? 60 : 30) : 0
            Behavior on rotation {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.3
                }
            }
        }
    }

    // ── Custom Styled Tooltip with Shortcut Badge ────────────────────────────
    ToolTip {
        id: tip
        visible: hov.hovered && !tapHandler.pressed
        delay: 350
        timeout: 4500
        x: root.width + 8
        y: Math.round((root.height - height) / 2)
        topPadding: 5
        bottomPadding: 5
        leftPadding: 9
        rightPadding: 9

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
                text: root.text
                color: theme.isDark ? "#FFFFFF" : "#1D1D1F"
                font.family: "Stack Sans Headline"
                font.pixelSize: 12
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                visible: root.shortcut !== ""
                width: shortcutLabel.implicitWidth + 8
                height: 18
                radius: 4
                color: theme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: shortcutLabel
                    anchors.centerIn: parent
                    text: root.shortcut
                    color: theme.isDark ? "#A0A0A5" : "#6E6E73"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        background: Rectangle {
            color: theme.isDark ? "#222225" : "#FFFFFF"
            border.color: theme.isDark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
            border.width: 1
            radius: 6
        }
    }

    HoverHandler {
        id: hov
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        id: tapHandler
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.clicked()
    }

    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
    activeFocusOnTab: true
}

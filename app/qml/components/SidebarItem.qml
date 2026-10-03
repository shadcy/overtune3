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

    CustomToolTip {
        id: tip
        visible: hov.hovered && !tapHandler.pressed
        x: root.width + 8
        y: Math.round((root.height - height) / 2)
        text: root.text
        shortcut: root.shortcut
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

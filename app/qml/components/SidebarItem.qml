import QtQuick
import QtQuick.Controls

// SidebarItem.qml — VS Code activity bar item using Codicons
Item {
    id: root
    width: parent ? parent.width : 48
    height: 48

    property bool   selected: false
    property string text: ""
    property string icon: "tools"   // Codicon name
    signal clicked()

    ToolTip.visible: hov.hovered
    ToolTip.delay: 450
    ToolTip.timeout: 4000
    ToolTip.text: root.text

    Rectangle {
        width: 2
        height: selected ? 22 : 0
        radius: 1
        color: theme.isDark ? "#FFFFFF" : "#1E1E1E"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: selected
        Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        radius: 6
        color: {
            if (selected)
                return theme.isDark ? "#2A2D2E" : "#D7D7D7"
            if (hov.hovered)
                return theme.isDark ? "#2A2D2E" : "#E4E4E4"
            return "transparent"
        }
        Behavior on color { ColorAnimation { duration: 100 } }

        Codicon {
            anchors.centerIn: parent
            icon: root.icon
            iconSize: 22
            iconColor: {
                if (selected)
                    return theme.isDark ? "#FFFFFF" : "#1E1E1E"
                if (hov.hovered)
                    return theme.isDark ? "#E0E0E0" : "#333333"
                return theme.isDark ? "#858585" : "#616161"
            }
            Behavior on iconColor { ColorAnimation { duration: 100 } }
        }
    }

    HoverHandler { id: hov }
    TapHandler {
        gesturePolicy: TapHandler.ReleaseWithinBounds
        onTapped: root.clicked()
    }

    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
    activeFocusOnTab: true
}

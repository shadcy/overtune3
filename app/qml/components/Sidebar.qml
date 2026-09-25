import QtQuick
import QtQuick.Controls

// Sidebar.qml — VS Code-style activity bar
Rectangle {
    id: root
    implicitWidth: 48
    width: 48
    color: theme.activityBarBg
    clip: true

    property int currentPage: 0

    readonly property var pages: [
        { text: "Design",       icon: "tools",         index: 0 },
        { text: "Analysis",     icon: "graph",         index: 1 },
        { text: "Simulation",   icon: "play",          index: 2 },
        { text: "Export",       icon: "export",        index: 3 },
        { text: "Documentation",icon: "book",          index: 4 }
    ]

    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: theme.borderColor
        opacity: 0.55
    }

    Column {
        id: topNav
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 6
        }
        spacing: 2

        Repeater {
            model: root.pages
            delegate: SidebarItem {
                required property var modelData
                text: modelData.text
                icon: modelData.icon
                selected: root.currentPage === modelData.index
                onClicked: root.currentPage = modelData.index
            }
        }
    }

    Column {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: 6
        }
        spacing: 2

        SidebarItem {
            text: "Settings"
            icon: "settings-gear"
            selected: root.currentPage === 5
            onClicked: root.currentPage = 5
        }
    }

    Behavior on color { ColorAnimation { duration: 250 } }
}

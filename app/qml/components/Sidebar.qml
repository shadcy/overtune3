import QtQuick
import QtQuick.Controls

// Sidebar.qml — VS Code-style activity bar with smooth, fluid sliding animations
Rectangle {
    id: root
    implicitWidth: 48
    width: 48
    color: theme.activityBarBg
    clip: true

    property int currentPage: 0

    readonly property var pages: [
        { text: "Design",        icon: "tools",         index: 0, shortcut: "Ctrl+1" },
        { text: "Analysis",      icon: "graph",         index: 1, shortcut: "Ctrl+2" },
        { text: "Simulation",    icon: "play",          index: 2, shortcut: "Ctrl+3" },
        { text: "Export",        icon: "export",        index: 3, shortcut: "Ctrl+4" },
        { text: "Documentation", icon: "book",          index: 4, shortcut: "Ctrl+5" }
    ]

    function getTargetY(pageIndex) {
        if (pageIndex >= 0 && pageIndex < 5) {
            return 6 + pageIndex * 50;
        } else if (pageIndex === 5) {
            return root.height - 54;
        }
        return 6;
    }

    property real indicatorY: 6
    property real indicatorStretch: 1.0

    onCurrentPageChanged: {
        var target = getTargetY(currentPage);
        if (Math.abs(indicatorY - target) > 0.5) {
            var dist = Math.abs(indicatorY - target);
            slideAnim.duration = Math.min(280, Math.max(200, 180 + dist * 0.16));
            slideYAnim.to = target;
            slideAnim.restart();
        }
    }

    onHeightChanged: {
        if (currentPage === 5 && !slideAnim.running) {
            indicatorY = getTargetY(5);
        }
    }

    Component.onCompleted: {
        indicatorY = getTargetY(currentPage);
    }

    ParallelAnimation {
        id: slideAnim
        property int duration: 220

        NumberAnimation {
            id: slideYAnim
            target: root
            property: "indicatorY"
            duration: slideAnim.duration
            easing.type: Easing.OutCubic
        }

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "indicatorStretch"
                to: 1.22
                duration: Math.round(slideAnim.duration * 0.45)
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: root
                property: "indicatorStretch"
                to: 1.0
                duration: Math.round(slideAnim.duration * 0.55)
                easing.type: Easing.OutBack
                easing.overshoot: 1.3
            }
        }
    }

    // ── Right Divider Line ───────────────────────────────────────────────────
    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: theme.borderColor
        opacity: 0.55
        z: 3
    }

    // ── Sliding Selection Background Pill ─────────────────────────────────────
    Rectangle {
        id: activePill
        x: 4
        y: Math.round(root.indicatorY + 4)
        width: root.width - 8
        height: 40
        radius: 8
        z: 0
        scale: 1.0 - (root.indicatorStretch - 1.0) * 0.12
        color: theme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)
        border.color: theme.isDark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.04)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on border.color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // ── Sliding Active Indicator Accent Bar ───────────────────────────────────
    Rectangle {
        id: activeIndicator
        x: 0
        width: 3
        height: Math.round(22 * root.indicatorStretch)
        y: Math.round(root.indicatorY + (48 - height) / 2)
        radius: 1.5
        z: 2
        color: theme.isDark ? "#FFFFFF" : theme.accent

        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // ── Top Navigation Items ──────────────────────────────────────────────────
    Column {
        id: topNav
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 6
        }
        spacing: 2
        z: 1

        Repeater {
            id: topNavRepeater
            model: root.pages
            delegate: SidebarItem {
                required property var modelData
                text: modelData.text
                icon: modelData.icon
                shortcut: modelData.shortcut
                selected: root.currentPage === modelData.index
                onClicked: root.currentPage = modelData.index
            }
        }
    }

    // ── Bottom Navigation Items (Settings) ────────────────────────────────────
    Column {
        id: bottomNav
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: 6
        }
        spacing: 2
        z: 1

        SidebarItem {
            id: settingsItem
            text: "Settings"
            icon: "settings-gear"
            shortcut: "Ctrl+,"
            selected: root.currentPage === 5
            onClicked: root.currentPage = 5
        }
    }

    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
}

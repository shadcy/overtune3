import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

// InstallerUpdaterWindow.qml — Standalone installer and auto-updater window with OLED theme & 16:9 banner
Window {
    id: root
    property bool isStandalone: false
    property int activeTab: 0 // 0 = Auto-Updater, 1 = System Installer
    readonly property bool updateBusy: updateInstaller.isChecking || updateInstaller.isDownloading || updateInstaller.isInstalling || updateInstaller.isReadyToRestart || updateInstaller.status === "verifying"

    title: (isStandalone || activeTab === 1) ? "Overtune " + updateInstaller.currentVersion + " Setup" : "Overtune " + updateInstaller.currentVersion + " — Installer & Auto-Updater"
    width:         520
    height:        Math.min(640, Screen.desktopAvailableHeight ? Screen.desktopAvailableHeight - 80 : 620)
    minimumWidth:  460
    minimumHeight: 460
    maximumWidth:  600
    maximumHeight: 760

    color: theme.background
    palette.window: theme.background
    palette.windowText: theme.primaryText
    palette.base: theme.surface
    palette.text: theme.primaryText
    palette.button: theme.surfaceHigh
    palette.buttonText: theme.primaryText
    palette.highlight: theme.accent
    palette.highlightedText: "#FFFFFF"
    palette.mid: theme.borderColor
    visible: false
    flags: isStandalone ? (Qt.Window | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint)
                        : (Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint)

    onClosing: function(close) {
        if (isStandalone) {
            Qt.quit()
        }
    }

    Component.onCompleted: {
        if (isStandalone) {
            openWindow(1)
        }
    }

    function openWindow(tabIndex) {
        if (tabIndex !== undefined) {
            activeTab = tabIndex
        }
        if (!visible) {
            if (transientParent) {
                x = Math.max(0, transientParent.x + (transientParent.width - width) / 2)
                y = Math.max(0, transientParent.y + (transientParent.height - height) / 2)
            } else if (Screen.desktopAvailableWidth && Screen.desktopAvailableHeight) {
                x = Math.max(0, (Screen.desktopAvailableWidth - width) / 2)
                y = Math.max(0, (Screen.desktopAvailableHeight - height) / 2)
            }
            visible = true
            fadeIn.restart()
        }
        raise()
        requestActivate()
    }

    function checkUpdatesNow() {
        openWindow(0)
        updateInstaller.checkForUpdates(true)
    }

    function openInstallerMode() {
        openWindow(1)
    }

    NumberAnimation {
        id: fadeIn
        target: scrollView
        property: "opacity"
        from: 0; to: 1
        duration: 240
        easing.type: Easing.OutCubic
    }

    Shortcut { sequence: "Escape"; onActivated: { root.close(); if (root.isStandalone) Qt.quit(); } }

    // ── Full scroll matching WhatsNewWindow / DesignVerifierModal ─────────────
    ScrollView {
        id: scrollView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: footer.top }
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical: ScrollBar {
            id: installerScrollBar
            policy: ScrollBar.AsNeeded
            hoverEnabled: true
            width: 8
            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: installerScrollBar.pressed ? theme.accent
                     : (installerScrollBar.hovered ? theme.secondaryText : theme.borderColor)
            }
            background: Item {}
        }

        Column {
            width: scrollView.availableWidth
            spacing: 0

            // ── Banner ───────────────────────────────────────────────────────
            Item {
                width: parent.width
                height: root.width * 9.0 / 16.0   // 292.5 px
                clip: true

                Image {
                    anchors.fill: parent
                    source: "qrc:/FilterDesigner/icons/banner.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }

                // Bottom gradient fade to match background
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 80
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: theme.background }
                    }
                }

            }

            // ── Content Padding Container ─────────────────────────────────────
            Column {
                width: parent.width - 48
                x: 24
                spacing: 16

                Item { width: 1; height: 2 }

                // Headline
                Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        text: (root.isStandalone || root.activeTab === 1)
                              ? (updateInstaller.status === "installed" ? "Overtune " + updateInstaller.currentVersion + " Ready to Launch" : "Install Overtune " + updateInstaller.currentVersion + " to " + updateInstaller.osName)
                              : (updateInstaller.isChecking ? "Checking for updates"
                                 : (updateInstaller.hasUpdate ? ("Update: v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion)
                                    : ("Overtune " + updateInstaller.currentVersion + " is up to date")))
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: theme.primaryText
                        lineHeight: 1.2
                        wrapMode: Text.Wrap
                        width: parent.width
                    }

                }

                // ── Mode Switcher Tabs (Segmented control) ────────────────────
                Rectangle {
                    visible: !root.isStandalone
                    width: parent.width
                    height: 36
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        spacing: 20

                        // Tab 0: In-App Updater
                        Rectangle {
                            width: (parent.width - 20) / 2
                            height: parent.height
                            color: "transparent"

                            Row {
                                anchors.centerIn: parent
                                spacing: 0
                                Text {
                                    text: "In-App Updater"
                                    font.pixelSize: 12
                                    font.weight: root.activeTab === 0 ? Font.DemiBold : Font.Normal
                                    color: root.activeTab === 0 ? theme.primaryText : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 2
                                color: root.activeTab === 0 ? theme.accent : "transparent"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeTab = 0
                            }
                        }

                        // Tab 1: System Installer
                        Rectangle {
                            width: (parent.width - 20) / 2
                            height: parent.height
                            color: "transparent"

                            Row {
                                anchors.centerIn: parent
                                spacing: 0
                                Text {
                                    text: "System Installer"
                                    font.pixelSize: 12
                                    font.weight: root.activeTab === 1 ? Font.DemiBold : Font.Normal
                                    color: root.activeTab === 1 ? theme.primaryText : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                                height: 2
                                color: root.activeTab === 1 ? theme.accent : "transparent"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeTab = 1
                            }
                        }
                    }
                }

                // ── Status and progress ──────────────────────────────────────
                Item {
                    width: parent.width
                    visible: root.updateBusy || ((root.isStandalone || root.activeTab === 1) && updateInstaller.status === "installed")
                    height: root.updateBusy ? 64 : 28

                    Column {
                        anchors.fill: parent
                        spacing: 8

                        // Top row: status label + icon + percentage
                        RowLayout {
                            width: parent.width

                            Row {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                Text {
                                    text: updateInstaller.isChecking ? "Checking for updates..."
                                          : (updateInstaller.isDownloading ? "Downloading update package..."
                                             : (updateInstaller.isInstalling ? "Applying & verifying update..."
                                                : (updateInstaller.isReadyToRestart ? "Ready to restart & update"
                                                   : (updateInstaller.status === "installed" ? "Installed to system"
                                                      : (updateInstaller.hasUpdate ? ("Update Available: v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion)
                                                         : ("Current Version: v" + updateInstaller.currentVersion))))))
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: theme.primaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: Math.round(updateInstaller.progress * 100) + "%"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: theme.accent
                                visible: root.updateBusy
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // Progress bar track
                        Rectangle {
                            id: progressTrack
                            width: parent.width
                            height: 6
                            visible: root.updateBusy
                            radius: 3
                            color: theme.surfaceHigh
                            clip: true

                            Rectangle {
                                id: progressFill
                                height: parent.height
                                width: Math.max(0, Math.min(progressTrack.width, progressTrack.width * updateInstaller.progress))
                                radius: 3
                                color: theme.accent
                                Behavior on width { NumberAnimation { duration: 100 } }
                            }
                        }

                            // Status detail
                        RowLayout {
                            width: parent.width
                            visible: root.updateBusy
                            Text {
                                text: updateInstaller.statusMessage
                                font.pixelSize: 11
                                color: theme.secondaryText
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: updateInstaller.isDownloading ? (updateInstaller.downloadSpeed + " • " + updateInstaller.releaseSize) : ""
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: theme.accent
                                visible: updateInstaller.isDownloading
                            }
                        }
                    }
                }

                // ── TAB 0: In-App Updater Details ─────────────────────────────
                Column {
                    width: parent.width
                    spacing: 12
                    visible: root.activeTab === 0 && updateInstaller.hasUpdate

                    // Release notes card
                    Item {
                        width: parent.width
                        implicitHeight: releaseCol.implicitHeight + 8

                        Column {
                            id: releaseCol
                            anchors { fill: parent; topMargin: 4; bottomMargin: 4 }
                            spacing: 10

                            RowLayout {
                                width: parent.width

                                Text {
                                    text: updateInstaller.hasUpdate
                                          ? ("v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion)
                                          : ("Overtune " + updateInstaller.currentVersion)
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: theme.primaryText
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: theme.borderColor
                            }

                            // Bullet points
                            Repeater {
                                model: updateInstaller.releaseNotes
                                delegate: Row {
                                    width: parent.width
                                    spacing: 8

                                    Text {
                                        width: parent.width
                                        text: modelData
                                        font.pixelSize: 12
                                        color: theme.primaryText
                                        wrapMode: Text.Wrap
                                        lineHeight: 1.3
                                    }
                                }
                            }

                            Item { width: 1; height: 4 }

                        }
                    }
                }

                // ── TAB 1: System Installer Configuration ─────────────────────
                Column {
                    width: parent.width
                    spacing: 12
                    visible: root.activeTab === 1

                    Item {
                        width: parent.width
                        implicitHeight: installConfigCol.implicitHeight + 8

                        Column {
                            id: installConfigCol
                            anchors { fill: parent; topMargin: 4; bottomMargin: 4 }
                            spacing: 12

                            // Destination directory with Browse button
                            Column {
                                width: parent.width
                                spacing: 4

                                Text {
                                    text: "Target Directory"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 34
                                    radius: 6
                                    color: theme.surfaceHigh
                                    border.color: theme.borderColor

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 6
                                        spacing: 8

                                        TextInput {
                                            id: pathInput
                                            text: updateInstaller.installPath
                                            font.pixelSize: 12
                                            color: theme.primaryText
                                            Layout.fillWidth: true
                                            clip: true
                                            verticalAlignment: TextInput.AlignVCenter
                                            selectByMouse: true
                                            onTextChanged: {
                                                if (updateInstaller.installPath !== text)
                                                    updateInstaller.installPath = text
                                            }
                                        }

                                        // Native Directory Browser Button
                                        Rectangle {
                                            implicitWidth: browseText.implicitWidth + 20
                                            implicitHeight: 24
                                            radius: 4
                                            color: browseMouse.pressed ? Qt.darker(theme.surface, 1.2) : (browseMouse.containsMouse ? theme.surfaceHigh : theme.surface)
                                            border.color: theme.borderColor

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 0
                                                Text {
                                                    id: browseText
                                                    text: "Browse..."
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    color: theme.primaryText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
                                            }

                                            MouseArea {
                                                id: browseMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var chosen = updateInstaller.browseDirectory("Select Installation Directory");
                                                    if (chosen && chosen.length > 0) {
                                                        pathInput.text = chosen;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Integration options (Desktop Shortcut, Application Menu)
                            Column {
                                width: parent.width
                                spacing: 8

                                // Option 1: Desktop Shortcut
                                Row {
                                    spacing: 8
                                    width: parent.width

                                    Rectangle {
                                        width: 18; height: 18
                                        radius: 4
                                        color: updateInstaller.createDesktopShortcut ? theme.accent : theme.surfaceHigh
                                        border.color: theme.borderColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        Codicon {
                                            icon: "check"
                                            iconSize: 12
                                            iconColor: "#FFFFFF"
                                            anchors.centerIn: parent
                                            visible: updateInstaller.createDesktopShortcut
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: updateInstaller.createDesktopShortcut = !updateInstaller.createDesktopShortcut
                                        }
                                    }

                                    Text {
                                        text: "Create Desktop Shortcut"
                                        font.pixelSize: 12
                                        color: theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Option 2: Application Menu / Start Menu
                                Row {
                                    spacing: 8
                                    width: parent.width

                                    Rectangle {
                                        width: 18; height: 18
                                        radius: 4
                                        color: updateInstaller.createStartMenu ? theme.accent : theme.surfaceHigh
                                        border.color: theme.borderColor
                                        anchors.verticalCenter: parent.verticalCenter

                                        Codicon {
                                            icon: "check"
                                            iconSize: 12
                                            iconColor: "#FFFFFF"
                                            anchors.centerIn: parent
                                            visible: updateInstaller.createStartMenu
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: updateInstaller.createStartMenu = !updateInstaller.createStartMenu
                                        }
                                    }

                                    Text {
                                        text: updateInstaller.osName === "Windows" ? "Register in Windows Start Menu & App List" : "Register in System Applications (~/.local/share/applications)"
                                        font.pixelSize: 12
                                        color: theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Item { width: 1; height: 4 }

                                // In-App Complete Uninstaller Button (visible when installed)
                                Rectangle {
                                    visible: updateInstaller.isInstalled
                                    width: parent.width
                                    height: 38
                                    radius: 7
                                    color: theme.isDark ? "#241214" : "#FFF0F0"
                                    border.color: theme.isDark ? "#802020" : "#FFCDD2"
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8

                                        Codicon {
                                            icon: "trash"
                                            iconSize: 13
                                            iconColor: theme.danger
                                        }

                                        Text {
                                            text: "Uninstall Overtune 3 from this system"
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                            color: theme.danger
                                            Layout.fillWidth: true
                                        }

                                        Rectangle {
                                            width: 76
                                            height: 24
                                            radius: 5
                                            color: uninsMouse.pressed ? Qt.darker(theme.danger, 1.2) : (uninsMouse.containsMouse ? Qt.lighter(theme.danger, 1.08) : theme.danger)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Uninstall"
                                                font.pixelSize: 11
                                                font.weight: Font.Bold
                                                color: "#FFFFFF"
                                            }

                                            MouseArea {
                                                id: uninsMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: uninstallConfirmDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }

    Dialog {
        id: uninstallConfirmDialog
        anchors.centerIn: parent
        modal: true
        width: Math.min(420, root.width - 32)
        padding: 0
        background: Rectangle {
            color: theme.surface
            border.color: theme.borderColor
            border.width: 1
            radius: 8
        }
        contentItem: Column {
            spacing: 0

            Item {
                width: parent.width
                height: 96

                Text {
                    anchors.fill: parent
                    anchors.margins: 20
                    text: "Remove Overtune 3 and its shortcuts from this device?"
                    color: theme.primaryText
                    font.family: theme.headlineFont
                    font.pixelSize: 14
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle { width: parent.width; height: 1; color: theme.borderColor }

            Item {
                width: parent.width
                height: 58

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    StyledButton {
                        text: "Cancel"
                        primary: false
                        implicitHeight: 32
                        onClicked: uninstallConfirmDialog.close()
                    }

                    StyledButton {
                        text: "Uninstall"
                        primary: false
                        danger: true
                        implicitHeight: 32
                        onClicked: {
                            uninstallConfirmDialog.close()
                            updateInstaller.uninstallFromSystem()
                        }
                    }
                }
            }
        }
    }

    // ── Sticky Footer ─────────────────────────────────────────────────────────
    Rectangle {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 60
        color: theme.surface
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: theme.borderColor
        }

        // Right button group
        Row {
            anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
            spacing: 8

            // Secondary "Cancel" / "Close" button when in installer mode
            Rectangle {
                visible: root.isStandalone || root.activeTab === 1
                implicitWidth:  closeBtnText.implicitWidth + 24
                implicitHeight: 30
                radius: 7
                color: closeMouse.containsMouse ? theme.surfaceHigh : theme.surface
                border.color: theme.borderColor
                border.width: 1

                Text {
                    id: closeBtnText
                    anchors.centerIn: parent
                    text: updateInstaller.status === "installed" ? "Close" : "Cancel"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: theme.primaryText
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close()
                        if (root.isStandalone) {
                            Qt.quit()
                        }
                    }
                }
            }

            // Primary Dynamic Accent Button
            Rectangle {
                id: actionBtn
                implicitWidth: Math.max(120, btnText.implicitWidth + 28)
                implicitHeight: 34
                radius: 7
                color: {
                    if (root.isStandalone || root.activeTab === 1) {
                        if (updateInstaller.status === "installing") return "#636366"
                    }
                    return btnMouse.pressed ? Qt.darker(theme.accent, 1.25) : (btnMouse.containsMouse ? Qt.lighter(theme.accent, 1.1) : theme.accent)
                }
                opacity: updateInstaller.isChecking ? 0.65 : 1
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text: {
                        if (root.isStandalone || root.activeTab === 1) {
                            if (updateInstaller.status === "installing") return "Installing..."
                            if (updateInstaller.status === "installed") return "Launch"
                            return "Install to System"
                        }
                        if (updateInstaller.isChecking) {
                            return "Checking..."
                        }
                        if (updateInstaller.isReadyToRestart) {
                            return "Restart & Update Now"
                        }
                        if (updateInstaller.isDownloading) {
                            return "Downloading..."
                        }
                        if (updateInstaller.isInstalling) {
                            return "Applying Update..."
                        }
                        if (updateInstaller.hasUpdate) {
                            return "Download & Install Update"
                        }
                        return "Check for Updates"
                    }
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    enabled: !updateInstaller.isChecking && updateInstaller.status !== "installing" && updateInstaller.status !== "verifying" && !updateInstaller.isDownloading && !updateInstaller.isInstalling
                    hoverEnabled: enabled
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (root.isStandalone || root.activeTab === 1) {
                            if (updateInstaller.status === "installed") {
                                updateInstaller.restartApplication()
                                root.close()
                                if (root.isStandalone) {
                                    Qt.quit()
                                }
                                return
                            }
                            if (updateInstaller.status !== "installing") {
                                updateInstaller.installToSystem(updateInstaller.installPath, updateInstaller.createDesktopShortcut, updateInstaller.createStartMenu)
                            }
                            return
                        }
                        if (updateInstaller.isChecking || updateInstaller.isDownloading || updateInstaller.isInstalling || updateInstaller.status === "verifying") {
                            return
                        }
                        if (updateInstaller.isReadyToRestart) {
                            updateInstaller.restartApplication()
                            return
                        }
                        if (updateInstaller.hasUpdate) {
                            updateInstaller.startDownloadAndInstall()
                            return
                        }
                        updateInstaller.checkForUpdates(false)
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

// InstallerUpdaterWindow.qml — Standalone installer and auto-updater window with OLED theme & 16:9 banner
Window {
    id: root
    property bool isStandalone: false
    property int activeTab: 0 // 0 = Auto-Updater, 1 = System Installer

    title: (isStandalone || activeTab === 1) ? "Overtune 3.2.3 Setup" : "Overtune 3.2.3 — Installer & Auto-Updater"
    width:         520
    height:        Math.min(640, Screen.desktopAvailableHeight ? Screen.desktopAvailableHeight - 80 : 620)
    minimumWidth:  460
    minimumHeight: 460
    maximumWidth:  600
    maximumHeight: 760

    color: theme.isDark ? (theme.oledMode ? "#000000" : "#111113") : "#F5F5F7"
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
        ScrollBar.vertical.policy:   ScrollBar.AsNeeded

        Column {
            width: scrollView.availableWidth
            spacing: 0

            // ── 16:9 Banner Header ────────────────────────────────────────────
            Item {
                width: parent.width
                height: root.width * 9.0 / 16.0   // 292.5 px
                clip: true

                Image {
                    anchors.fill: parent
                    source: "qrc:/FilterDesigner/icons/16-9ar-logo.png"
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
                        GradientStop { position: 1.0; color: theme.isDark ? (theme.oledMode ? "#000000" : "#111113") : "#F5F5F7" }
                    }
                }

                // Updater / Installer Pill — Top Right
                Rectangle {
                    anchors { top: parent.top; right: parent.right; margins: 14 }
                    height: 22
                    width: pillLabel.implicitWidth + 22
                    radius: 11
                    color: "#000000"
                    opacity: 0.85
                    border.color: "#FFFFFF"
                    border.width: 1

                    Text {
                        id: pillLabel
                        anchors.centerIn: parent
                        text: (root.isStandalone || root.activeTab === 1)
                              ? (updateInstaller.status === "installed" ? "INSTALLED ✓" : "SYSTEM INSTALLER")
                              : (updateInstaller.hasUpdate ? "UPDATE AVAILABLE" : "UP TO DATE")
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: (root.isStandalone || root.activeTab === 1)
                               ? (updateInstaller.status === "installed" ? "#30D158" : "#FFFFFF")
                               : (updateInstaller.hasUpdate ? theme.accent : "#30D158")
                        font.letterSpacing: 1.2
                    }
                }
            }

            // ── Content Padding Container ─────────────────────────────────────
            Column {
                width: parent.width - 48
                x: 24
                spacing: 16

                Item { width: 1; height: 2 }

                // Headline + Subtitle
                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: (root.isStandalone || root.activeTab === 1)
                              ? (updateInstaller.status === "installed" ? "Overtune 3.2.3 Ready to Launch" : "Install Overtune " + updateInstaller.currentVersion + " to " + updateInstaller.osName)
                              : (updateInstaller.hasUpdate ? ("Update: v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion) : ("Overtune " + updateInstaller.currentVersion + " is Up to Date"))
                        font.pixelSize: 24
                        font.weight: Font.Bold
                        color: theme.primaryText
                        lineHeight: 1.2
                    }

                    Text {
                        text: (root.isStandalone || root.activeTab === 1)
                              ? (updateInstaller.status === "installed"
                                 ? "Installation completed successfully. You can launch Overtune 3.2.3 now or close this wizard."
                                 : "Setup native system integration, desktop shortcuts, and Start menu registration.")
                              : (updateInstaller.hasUpdate ? ("Upgrade from v" + updateInstaller.currentVersion + " to v" + updateInstaller.latestVersion + " is ready to install.") : ("You are currently running the latest stable release (v" + updateInstaller.currentVersion + ")."))
                        font.pixelSize: 13
                        color: theme.secondaryText
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                }

                // ── Mode Switcher Tabs (Segmented control) ────────────────────
                Rectangle {
                    visible: !root.isStandalone
                    width: parent.width
                    height: 34
                    radius: 8
                    color: theme.surfaceHigh
                    border.color: theme.borderColor
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        // Tab 0: In-App Updater
                        Rectangle {
                            width: (parent.width - 2) / 2
                            height: parent.height
                            radius: 6
                            color: root.activeTab === 0 ? theme.surface : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Codicon {
                                    icon: "cloud-download"
                                    iconSize: 13
                                    iconColor: root.activeTab === 0 ? theme.accent : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "In-App Updater"
                                    font.pixelSize: 12
                                    font.weight: root.activeTab === 0 ? Font.DemiBold : Font.Normal
                                    color: root.activeTab === 0 ? theme.primaryText : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeTab = 0
                            }
                        }

                        // Tab 1: System Installer
                        Rectangle {
                            width: (parent.width - 2) / 2
                            height: parent.height
                            radius: 6
                            color: root.activeTab === 1 ? theme.surface : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6
                                Codicon {
                                    icon: "package"
                                    iconSize: 13
                                    iconColor: root.activeTab === 1 ? theme.accent : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "System Installer"
                                    font.pixelSize: 12
                                    font.weight: root.activeTab === 1 ? Font.DemiBold : Font.Normal
                                    color: root.activeTab === 1 ? theme.primaryText : theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeTab = 1
                            }
                        }
                    }
                }

                // ── Progress Card ─────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    height: 84
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        // Top row: status label + icon + percentage
                        RowLayout {
                            width: parent.width

                            Row {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 8

                                Codicon {
                                    id: spinIcon
                                    icon: updateInstaller.isChecking || updateInstaller.isDownloading || updateInstaller.isInstalling
                                          ? "sync"
                                          : (updateInstaller.status === "ready_to_restart" || updateInstaller.status === "installed"
                                             ? "pass-filled" : (updateInstaller.status === "error" ? "error" : "info"))
                                    iconSize: 14
                                    iconColor: updateInstaller.status === "error" ? "#FF3B30" : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter

                                    RotationAnimator {
                                        target: spinIcon
                                        running: updateInstaller.isChecking || updateInstaller.isDownloading || updateInstaller.isInstalling
                                        from: 0; to: 360; duration: 800; loops: Animation.Infinite
                                    }
                                }

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
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // Progress bar track
                        Rectangle {
                            id: progressTrack
                            width: parent.width
                            height: 6
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

                        // Subtitle info line
                        RowLayout {
                            width: parent.width
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
                    visible: root.activeTab === 0

                    // Release notes card
                    Rectangle {
                        width: parent.width
                        implicitHeight: releaseCol.implicitHeight + 28
                        radius: 12
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: releaseCol
                            anchors { fill: parent; margins: 14 }
                            spacing: 10

                            RowLayout {
                                width: parent.width

                                Rectangle {
                                    width: newTag.implicitWidth + 12
                                    height: 20
                                    radius: 4
                                    color: theme.accent

                                    Text {
                                        id: newTag
                                        anchors.centerIn: parent
                                        text: updateInstaller.hasUpdate ? ("v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion) : ("v" + updateInstaller.currentVersion)
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: "#FFFFFF"
                                    }
                                }

                                Text {
                                    text: updateInstaller.releaseName
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: theme.primaryText
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: updateInstaller.releaseDate
                                    font.pixelSize: 11
                                    color: theme.secondaryText
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

                                    Codicon {
                                        icon: "check"
                                        iconSize: 12
                                        iconColor: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        width: parent.width - 24
                                        text: modelData
                                        font.pixelSize: 12
                                        color: theme.primaryText
                                        wrapMode: Text.Wrap
                                        lineHeight: 1.3
                                    }
                                }
                            }

                            Item { width: 1; height: 4 }

                            // SHA256 integrity tag
                            Rectangle {
                                width: parent.width
                                height: 26
                                radius: 6
                                color: theme.surfaceHigh
                                border.color: theme.borderColor

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8

                                    Codicon {
                                        icon: "shield"
                                        iconSize: 12
                                        iconColor: "#30D158"
                                    }

                                    Text {
                                        text: "SHA-256 Verified: " + updateInstaller.releaseSha256.substring(0, 16) + "..."
                                        font.pixelSize: 10
                                        font.family: "Monospace"
                                        color: theme.secondaryText
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }

                // ── TAB 1: System Installer Configuration ─────────────────────
                Column {
                    width: parent.width
                    spacing: 12
                    visible: root.activeTab === 1

                    Rectangle {
                        width: parent.width
                        implicitHeight: installConfigCol.implicitHeight + 28
                        radius: 12
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: installConfigCol
                            anchors { fill: parent; margins: 14 }
                            spacing: 12

                            Text {
                                text: "Installation Destination & Integration"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

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

                                        Codicon {
                                            icon: "folder"
                                            iconSize: 14
                                            iconColor: theme.accent
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

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
                                            color: browseMouse.pressed ? Qt.darker(theme.surface, 1.2) : (browseMouse.containsMouse ? theme.surfaceHover : theme.surface)
                                            border.color: theme.borderColor

                                            Row {
                                                anchors.centerIn: parent
                                                spacing: 4
                                                Codicon {
                                                    icon: "folder-opened"
                                                    iconSize: 12
                                                    iconColor: theme.primaryText
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }
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

                                // Option 3: Command line symlink
                                Row {
                                    spacing: 8
                                    width: parent.width

                                    Codicon {
                                        icon: "terminal"
                                        iconSize: 14
                                        iconColor: "#30D158"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: "CLI Tool: overtune3 command will be linked in PATH"
                                        font.pixelSize: 12
                                        color: theme.secondaryText
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
                                            iconColor: "#FF453A"
                                        }

                                        Text {
                                            text: "Uninstall Overtune 3 from this system"
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                            color: "#FF453A"
                                            Layout.fillWidth: true
                                        }

                                        Rectangle {
                                            width: 76
                                            height: 24
                                            radius: 5
                                            color: uninsMouse.pressed ? "#CC2D24" : (uninsMouse.containsMouse ? "#E0382E" : "#A8241D")

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
        title: "Confirm Complete Uninstallation"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        contentItem: Text {
            text: "Are you sure you want to completely remove Overtune 3, its shortcuts, registry entries, and local files?"
            color: theme.primaryText
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            width: 380
        }
        onAccepted: {
            updateInstaller.uninstallFromSystem()
        }
    }

    // ── Sticky Footer ─────────────────────────────────────────────────────────
    Rectangle {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 60
        color: theme.isDark ? "#0C0C0E" : "#EBEBED"
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: theme.borderColor
        }

        // Left caption
        Text {
            anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
            text: updateInstaller.osName + " • " + (updateInstaller.updateChannel === "stable" ? "Stable Channel" : "Beta Channel")
            font.pixelSize: 11
            color: theme.secondaryText
            font.letterSpacing: 0.4
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

            // "Check for Updates" secondary button (when in updater mode and not standalone)
            Rectangle {
                visible: !root.isStandalone && root.activeTab === 0 && !updateInstaller.isDownloading && !updateInstaller.isInstalling && !updateInstaller.isReadyToRestart
                implicitWidth:  126
                implicitHeight: 30
                radius: 7
                color: checkMouse.containsMouse ? theme.surfaceHigh : theme.surface
                border.color: theme.borderColor
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 5
                    Codicon {
                        icon: "refresh"
                        iconSize: 12
                        iconColor: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Check Updates"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: checkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: updateInstaller.checkForUpdates(true)
                }
            }

            // Primary Dynamic Accent Button
            Rectangle {
                id: actionBtn
                implicitWidth:  btnText.implicitWidth + 24
                implicitHeight: 30
                radius: 7
                color: {
                    if (root.isStandalone || root.activeTab === 1) {
                        if (updateInstaller.status === "installed") return "#30D158"
                        if (updateInstaller.status === "installing") return "#636366"
                    }
                    return btnMouse.pressed ? Qt.darker(theme.accent, 1.25) : (btnMouse.containsMouse ? Qt.lighter(theme.accent, 1.1) : theme.accent)
                }
                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    id: btnText
                    anchors.centerIn: parent
                    text: {
                        if (root.isStandalone || root.activeTab === 1) {
                            if (updateInstaller.status === "installing") return "Installing..."
                            if (updateInstaller.status === "installed") return "Launch Overtune 3"
                            return "Install to System"
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
                    hoverEnabled: updateInstaller.status !== "installing"
                    cursorShape: updateInstaller.status === "installing" ? Qt.ArrowCursor : Qt.PointingHandCursor
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

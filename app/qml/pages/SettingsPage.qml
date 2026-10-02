import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property int pageMargin: width < 700 ? 12 : 20
    readonly property real cardMax: 620

    function openDocs() {
        const w = Window.window
        if (w && typeof w.navigateTo === "function") w.navigateTo(4)
    }

    function doResetDefaults() {
        theme.resetToDefaults()
        const w = Window.window
        if (w && typeof w.showNotification === "function")
            w.showNotification("Settings restored to defaults", false)
    }

    // ── Reusable row: label left, control right ───────────────────────────────
    component SettingRow: Item {
        id: sr
        property string label: ""
        property string hint:  ""
        default property alias content: controlSlot.data
        width: parent ? parent.width : 200
        height: Math.max(44, controlSlot.implicitHeight + 20)

        Text {
            id: srLabel
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            text: sr.label
            font.family: "Stack Sans Headline"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: theme.primaryText
        }

        Item {
            id: controlSlot
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }

        // hairline separator
        Rectangle {
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: 1
            color: theme.borderColor
            opacity: 0.5
        }
    }

    // ── Page layout ───────────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.pageMargin
        spacing: 12

        PageHeader {
            Layout.fillWidth: true
            title: "Settings"
            badgeText: "v3.2.0"
            badgeIcon: "settings-gear"

            Rectangle {
                implicitHeight: 26
                implicitWidth: resetRow.implicitWidth + 14
                radius: 6
                color: resetMouse.containsMouse ? theme.surfaceHigh : theme.surface
                border.color: theme.borderColor
                border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }

                Row {
                    id: resetRow
                    anchors.centerIn: parent
                    spacing: 5
                    Codicon {
                        icon: "refresh"; iconSize: 11
                        iconColor: theme.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Reset"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: theme.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: resetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doResetDefaults()
                }
            }
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight + 40
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar {
                policy: flick.contentHeight > flick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: contentCol
                width: Math.min(root.cardMax, flick.width)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                // ── Appearance ────────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: appCol.implicitHeight + 24
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: appCol
                        anchors { fill: parent; margins: 0; topMargin: 0 }
                        spacing: 0

                        // Section label
                        Text {
                            x: 16; topPadding: 14; bottomPadding: 8
                            text: "APPEARANCE"
                            font.pixelSize: 10; font.weight: Font.Bold
                            font.letterSpacing: 1.4
                            color: theme.secondaryText
                        }

                        // Theme
                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Theme"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 200; implicitHeight: 28
                                model: ["System", "Light", "Dark"]
                                currentIndex: theme.themeMode
                                onActivated: function(idx) { theme.themeMode = idx }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // OLED Black
                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "OLED Black"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 160; implicitHeight: 28
                                model: ["Off", "On"]
                                currentIndex: theme.oledMode ? 1 : 0
                                onActivated: function(idx) { theme.oledMode = (idx === 1) }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // Accent Color — only 2 options
                        Item {
                            width: parent.width; height: 52
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Accent"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            Row {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                spacing: 10

                                Repeater {
                                    model: [
                                        { name: "Blue",          color: "#0A84FF", idx: 0 },
                                        { name: "Spotify Green", color: "#1DB954", idx: 1 }
                                    ]
                                    delegate: Rectangle {
                                        required property int index
                                        required property var modelData
                                        width: 28; height: 28; radius: 14
                                        color: modelData.color
                                        border.color: theme.accentColorIndex === modelData.idx ? "#FFFFFF" : "transparent"
                                        border.width: 2

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 9; height: 9; radius: 5
                                            color: "#FFFFFF"
                                            visible: theme.accentColorIndex === modelData.idx
                                        }

                                        ToolTip.visible: sm.containsMouse
                                        ToolTip.text: modelData.name
                                        ToolTip.delay: 300

                                        MouseArea {
                                            id: sm
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: theme.accentColorIndex = modelData.idx
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Plot Engine ───────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: plotCol.implicitHeight + 24
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: plotCol
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        Text {
                            x: 16; topPadding: 14; bottomPadding: 8
                            text: "PLOTS"
                            font.pixelSize: 10; font.weight: Font.Bold
                            font.letterSpacing: 1.4
                            color: theme.secondaryText
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Line Width"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 200; implicitHeight: 28
                                model: ["Fine", "Standard", "Bold"]
                                currentIndex: {
                                    if (Math.abs(theme.plotLineWidth - 1.5) < 0.2) return 0
                                    if (Math.abs(theme.plotLineWidth - 3.2) < 0.2) return 2
                                    return 1
                                }
                                onActivated: function(idx) {
                                    theme.plotLineWidth = [1.5, 2.2, 3.2][idx]
                                }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Resolution"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 240; implicitHeight: 28
                                model: ["512", "1024", "2048", "4096"]
                                currentIndex: {
                                    if (theme.plotResolution === 512)  return 0
                                    if (theme.plotResolution === 2048) return 2
                                    if (theme.plotResolution === 4096) return 3
                                    return 1
                                }
                                onActivated: function(idx) {
                                    theme.plotResolution = [512, 1024, 2048, 4096][idx]
                                }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Crosshair"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 140; implicitHeight: 28
                                model: ["Off", "On"]
                                currentIndex: theme.showCrosshairByDefault ? 1 : 0
                                onActivated: function(idx) { theme.showCrosshairByDefault = (idx === 1) }
                            }
                        }
                    }
                }

                // ── DSP & Export ──────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: dspCol2.implicitHeight + 24
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: dspCol2
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        Text {
                            x: 16; topPadding: 14; bottomPadding: 8
                            text: "DSP & EXPORT"
                            font.pixelSize: 10; font.weight: Font.Bold
                            font.letterSpacing: 1.4
                            color: theme.secondaryText
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Sample Rate"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 220; implicitHeight: 28
                                model: ["44.1 kHz", "48 kHz", "96 kHz"]
                                currentIndex: {
                                    if (theme.defaultSampleRate === 44100) return 0
                                    if (theme.defaultSampleRate === 96000) return 2
                                    return 1
                                }
                                onActivated: function(idx) {
                                    const rates = [44100, 48000, 96000]
                                    theme.defaultSampleRate = rates[idx]
                                    filterEngine.sampleRate = rates[idx]
                                }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Export Language"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 240; implicitHeight: 28
                                model: ["C++20", "C99", "Python", "JSON"]
                                currentIndex: theme.defaultExportLang
                                onActivated: function(idx) { theme.defaultExportLang = idx }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Animations"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            SegmentedButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: 140; implicitHeight: 28
                                model: ["Off", "On"]
                                currentIndex: theme.animationsEnabled ? 1 : 0
                                onActivated: function(idx) { theme.animationsEnabled = (idx === 1) }
                            }
                        }
                    }
                }

                // ── Installation & Updates ─────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: updateCardCol.implicitHeight + 20
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: updateCardCol
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        Text {
                            x: 16; topPadding: 14; bottomPadding: 8
                            text: "INSTALLATION & UPDATES"
                            font.pixelSize: 10; font.weight: Font.Bold
                            font.letterSpacing: 1.4
                            color: theme.secondaryText
                        }

                        // Row 1: Current status + Check for Updates button
                        Item {
                            width: parent.width; height: 50
                            RowLayout {
                                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                spacing: 12

                                Codicon {
                                    icon: "cloud-download"
                                    iconSize: 18
                                    iconColor: theme.accent
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Overtune " + updateInstaller.currentVersion + " (" + updateInstaller.osName + " Native)"
                                        font.family: "Stack Sans Headline"; font.pixelSize: 13
                                        font.weight: Font.DemiBold; color: theme.primaryText
                                    }
                                    Text {
                                        text: updateInstaller.hasUpdate ? ("Update v" + updateInstaller.latestVersion + " available") : "Up to date • Stable release channel"
                                        font.pixelSize: 11
                                        color: updateInstaller.hasUpdate ? theme.accent : theme.secondaryText
                                    }
                                }

                                StyledButton {
                                    text: "Check Updates"
                                    primary: true
                                    implicitWidth: 110; implicitHeight: 28
                                    onClicked: {
                                        const w = Window.window
                                        if (w && typeof w.checkUpdatesNow === "function") {
                                            w.checkUpdatesNow()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // Row 2: Install Path & Setup Shortcuts
                        Item {
                            width: parent.width; height: 50
                            RowLayout {
                                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                spacing: 12

                                Codicon {
                                    icon: "package"
                                    iconSize: 18
                                    iconColor: theme.secondaryText
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "System Installation"
                                        font.family: "Stack Sans Headline"; font.pixelSize: 13
                                        font.weight: Font.DemiBold; color: theme.primaryText
                                    }
                                    Text {
                                        text: updateInstaller.installPath
                                        font.pixelSize: 11
                                        color: theme.secondaryText
                                        elide: Text.ElideMiddle
                                    }
                                }

                                StyledButton {
                                    text: "Installer Setup"
                                    primary: false
                                    implicitWidth: 110; implicitHeight: 28
                                    onClicked: {
                                        const w = Window.window
                                        if (w && typeof w.showInstallerUpdater === "function") {
                                            w.showInstallerUpdater(1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── About ─────────────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: aboutCol2.implicitHeight + 24
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true


                    Column {
                        id: aboutCol2
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        Text {
                            x: 16; topPadding: 14; bottomPadding: 8
                            text: "ABOUT"
                            font.pixelSize: 10; font.weight: Font.Bold
                            font.letterSpacing: 1.4
                            color: theme.secondaryText
                        }

                        Repeater {
                            model: [
                                { label: "App",       value: "Overtune 3 Studio" },
                                { label: "Version",   value: "3.2.0" },
                                { label: "DSP Engine",value: "C++20, zero dependencies" },
                                { label: "UI",        value: "Qt 6 / QML" }
                            ]
                            delegate: Item {
                                width: parent.width; height: 36
                                Text {
                                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.label
                                    font.family: "Stack Sans Headline"; font.pixelSize: 13
                                    color: theme.secondaryText
                                }
                                Text {
                                    anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.value
                                    font.family: "Stack Sans Headline"; font.pixelSize: 13
                                    color: theme.primaryText
                                }
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                    height: 1; color: theme.borderColor
                                    opacity: index < 3 ? 0.5 : 0
                                }
                            }
                        }
                    }
                }

                // ── Docs banner ───────────────────────────────────────────────
                Rectangle {
                    width: parent.width; height: 60
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor; border.width: 1
                    clip: true

                    Codicon {
                        id: docsIco
                        anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                        icon: "book"; iconSize: 20; iconColor: theme.accent
                    }
                    Text {
                        anchors {
                            left: docsIco.right; leftMargin: 12
                            right: openBtn.left; rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        text: "DSP Theory & Tutorials"
                        font.family: "Stack Sans Headline"; font.pixelSize: 13
                        font.weight: Font.DemiBold; color: theme.primaryText
                        elide: Text.ElideRight
                    }
                    StyledButton {
                        id: openBtn
                        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                        text: "Open"; primary: true
                        implicitWidth: 72; implicitHeight: 30
                        onClicked: root.openDocs()
                    }
                }

                Item { width: 1; height: 8 }
            }
        }
    }
}

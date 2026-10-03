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
    readonly property bool compact: width < 520

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

    Rectangle {
        anchors.fill: parent
        color: theme.background
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
                id: settingsScrollBar
                policy: flick.contentHeight > flick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                width: 8
                hoverEnabled: true
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: settingsScrollBar.pressed ? theme.accent
                         : (settingsScrollBar.hovered ? theme.secondaryText : theme.borderColor)
                }
                background: Item {}
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
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "Appearance"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        // Theme
                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; right: themeControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Theme"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: themeControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(200, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: oledControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "OLED Black"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: oledControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(160, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: accentControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Accent"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            Row {
                                id: accentControl
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

                                        CustomToolTip {
                                            visible: sm.containsMouse
                                            text: modelData.name
                                        }

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

                        Item {
                            width: parent.width; height: 48
                            Text {
                                anchors { left: parent.left; leftMargin: 16; right: resetSettingsButton.left; rightMargin: 12; verticalCenter: parent.verticalCenter }
                                text: "Reset settings"
                                font.family: theme.headlineFont
                                font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            StyledButton {
                                id: resetSettingsButton
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Reset"
                                primary: false
                                implicitWidth: 84
                                implicitHeight: 30
                                onClicked: root.doResetDefaults()
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
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "Plots"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; right: lineWidthControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Line Width"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: lineWidthControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(200, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: resolutionControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Resolution"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: resolutionControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(240, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: crosshairControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Crosshair"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: crosshairControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(140, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "DSP & Export"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; right: sampleRateControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Sample Rate"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: sampleRateControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(220, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: exportControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Export Language"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: exportControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(240, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                                anchors { left: parent.left; leftMargin: 16; right: animationControl.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                text: "Animations"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            SegmentedButton {
                                id: animationControl
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                width: Math.min(140, parent.width * (root.compact ? 0.55 : 0.7)); implicitHeight: 28
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
                    implicitHeight: updateCardCol.implicitHeight + 16
                    height: implicitHeight
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
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "Updates"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        // Row 1: Current status + Check for Updates button
                        Item {
                            width: parent.width; height: 50
                            RowLayout {
                                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                spacing: 12

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Overtune 3 · v" + updateInstaller.currentVersion
                                        font.family: theme.headlineFont; font.pixelSize: 13
                                        font.weight: Font.DemiBold; color: theme.primaryText
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: updateInstaller.hasUpdate
                                              ? ("v" + updateInstaller.currentVersion + " → v" + updateInstaller.latestVersion)
                                              : "Up to date"
                                        font.family: theme.bodyFont
                                        font.pixelSize: 12
                                        color: updateInstaller.hasUpdate ? theme.accent : theme.secondaryText
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }

                                StyledButton {
                                    text: "Check"
                                    primary: true
                                    implicitWidth: 84
                                    implicitHeight: 30
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

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "System Installation"
                                        font.family: theme.headlineFont; font.pixelSize: 13
                                        font.weight: Font.DemiBold; color: theme.primaryText
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: updateInstaller.installPath
                                        font.family: theme.bodyFont
                                        font.pixelSize: 12
                                        color: theme.secondaryText
                                        elide: Text.ElideMiddle
                                    }
                                }

                                StyledButton {
                                    text: "Setup"
                                    primary: false
                                    implicitWidth: 84
                                    implicitHeight: 30
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

                // ── AI Provider ───────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: aiColumn.implicitHeight + 16
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: aiColumn
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        // Section header row with status on right
                        Item {
                            width: parent.width; height: 44
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "AI Assistant"
                                font.family: theme.headlineFont
                                font.pixelSize: 16; font.weight: Font.DemiBold
                                color: theme.primaryText
                            }
                            Text {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                text: chat.apiKeyConfigured ? "Connected" : "Not connected"
                                color: chat.apiKeyConfigured ? theme.accent : theme.secondaryText
                                font.family: theme.bodyFont
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // Model ID row
                        Item {
                            width: parent.width; height: 50
                            Text {
                                id: modelLabel
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Model ID"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            Rectangle {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter; left: modelLabel.right; leftMargin: 16 }
                                height: 32
                                radius: 6
                                color: theme.background
                                border.color: openRouterModel.activeFocus ? theme.accent : theme.borderColor
                                border.width: 1

                                TextInput {
                                    id: openRouterModel
                                    anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: chat.modelName
                                    color: theme.primaryText
                                    selectedTextColor: "#FFFFFF"
                                    selectionColor: theme.accent
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    selectByMouse: true
                                    onEditingFinished: chat.modelName = text
                                    Text {
                                        visible: !openRouterModel.text.length && !openRouterModel.activeFocus
                                        text: "e.g. anthropic/claude-3.5-sonnet"
                                        color: theme.secondaryText
                                        font: openRouterModel.font
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // API Key row
                        Item {
                            width: parent.width; height: 54
                            Text {
                                id: keyLabel
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "API Key"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            RowLayout {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter; left: keyLabel.right; leftMargin: 16 }
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 32
                                    radius: 6
                                    color: theme.background
                                    border.color: openRouterKey.activeFocus ? theme.accent : theme.borderColor
                                    border.width: 1

                                    TextInput {
                                        id: openRouterKey
                                        anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                                        verticalAlignment: TextInput.AlignVCenter
                                        echoMode: TextInput.Password
                                        color: theme.primaryText
                                        selectedTextColor: "#FFFFFF"
                                        selectionColor: theme.accent
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        selectByMouse: true
                                        Text {
                                            visible: !openRouterKey.text.length && !openRouterKey.activeFocus
                                            text: chat.apiKeyConfigured ? "Key stored securely" : "Paste OpenRouter API key"
                                            color: theme.secondaryText
                                            font: openRouterKey.font
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                }

                                StyledButton {
                                    text: "Save"
                                    primary: true
                                    implicitWidth: 64
                                    implicitHeight: 32
                                    enabled: openRouterKey.text.trim().length > 0
                                    onClicked: {
                                        chat.saveApiKey(openRouterKey.text)
                                        openRouterKey.clear()
                                    }
                                }

                                StyledButton {
                                    text: "Clear"
                                    primary: false
                                    implicitWidth: 64
                                    implicitHeight: 32
                                    enabled: chat.apiKeyConfigured
                                    onClicked: chat.clearApiKey()
                                }
                            }
                        }

                        // Footer hint
                        Item {
                            width: parent.width; height: 32
                            Text {
                                anchors { left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                text: Qt.platform.os === "windows"
                                      ? "Key is protected using Windows DPAPI encryption. Requests connect directly to OpenRouter."
                                      : "Key is stored for this session. Requests connect directly to OpenRouter."
                                color: theme.secondaryText
                                font.family: theme.bodyFont
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // ── About ─────────────────────────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: aboutCol2.implicitHeight + 16
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
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "About"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Repeater {
                            model: [
                                { label: "Application", value: "Overtune 3" },
                                { label: "Version", value: "v" + updateInstaller.currentVersion }
                            ]
                            delegate: Item {
                                width: parent.width; height: 44
                                Text {
                                    id: aboutLabel
                                    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.label
                                    font.family: "Stack Sans Headline"; font.pixelSize: 13
                                    color: theme.primaryText
                                }
                                Text {
                                    anchors { left: aboutLabel.right; leftMargin: 12; right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                    text: modelData.value
                                    font.family: theme.bodyFont; font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: theme.secondaryText
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideLeft
                                }
                                Rectangle {
                                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                    height: 1; color: theme.borderColor
                                    opacity: index < 1 ? 0.5 : 0
                                }
                            }
                        }
                    }
                }

                // ── Maintenance & Resources ──────────────────────────────────
                Rectangle {
                    width: parent.width
                    implicitHeight: maintCol.implicitHeight + 16
                    height: implicitHeight
                    radius: 12
                    color: theme.surface
                    border.color: theme.borderColor
                    border.width: 1
                    clip: true

                    Column {
                        id: maintCol
                        anchors { fill: parent; margins: 0 }
                        spacing: 0

                        Text {
                            x: 16; topPadding: 16; bottomPadding: 10
                            text: "Resources & Maintenance"
                            font.family: theme.headlineFont
                            font.pixelSize: 16; font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        // Documentation Row
                        Item {
                            width: parent.width; height: 50
                            Text {
                                anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "DSP Theory & Documentation"
                                font.family: "Stack Sans Headline"; font.pixelSize: 13
                                color: theme.primaryText
                            }
                            StyledButton {
                                anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
                                text: "Open"; primary: true
                                implicitWidth: 84; implicitHeight: 30
                                onClicked: root.openDocs()
                            }
                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right; leftMargin: 16 }
                                height: 1; color: theme.borderColor; opacity: 0.5
                            }
                        }

                        // Uninstall Row
                        Item {
                            width: parent.width; height: 50
                            RowLayout {
                                anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                                spacing: 12

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Uninstall Overtune 3"
                                        font.family: "Stack Sans Headline"; font.pixelSize: 13
                                        color: theme.primaryText
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: "Remove application and desktop shortcuts"
                                        font.family: theme.bodyFont; font.pixelSize: 12
                                        color: theme.secondaryText
                                        Layout.fillWidth: true
                                    }
                                }

                                StyledButton {
                                    text: "Uninstall"
                                    primary: false
                                    danger: true
                                    implicitWidth: 84
                                    implicitHeight: 30
                                    onClicked: settingsUninsDialog.open()
                                }
                            }
                        }
                    }
                }

                Item { width: 1; height: 8 }
            }
        }
    }

    Dialog {
        id: settingsUninsDialog
        title: "Uninstall Overtune 3"
        anchors.centerIn: parent
        modal: true
        width: Math.min(440, root.width - 32)
        padding: 0
        palette.window: theme.surface
        palette.windowText: theme.primaryText
        background: Rectangle {
            color: theme.surface
            border.color: theme.borderColor
            border.width: 1
            radius: 12
            clip: true
        }
        contentItem: Column {
            spacing: 0

            Item {
                width: parent.width - 40
                height: uninstallCopy.implicitHeight + 36
                x: 20

                Column {
                    id: uninstallCopy
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 6

                    Text {
                        width: parent.width
                        text: "Uninstall Overtune 3?"
                        font.family: theme.headlineFont
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        wrapMode: Text.Wrap
                    }

                    Text {
                        width: parent.width
                        text: "The app and its shortcuts will be removed."
                        font.family: theme.bodyFont
                        font.pixelSize: 14
                        color: theme.primaryText
                        wrapMode: Text.Wrap
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: theme.borderColor }

            Item {
                width: parent.width - 40
                height: 62
                x: 20

                Row {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                    spacing: 10

                    StyledButton {
                        text: "Cancel"
                        primary: false
                        implicitHeight: 34
                        onClicked: settingsUninsDialog.close()
                    }

                    StyledButton {
                        text: "Uninstall"
                        primary: false
                        danger: true
                        implicitHeight: 34
                        onClicked: {
                            settingsUninsDialog.close()
                            updateInstaller.uninstallFromSystem()
                        }
                    }
                }
            }
        }
    }
}

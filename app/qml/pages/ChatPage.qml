import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    property int pageMargin: width < 600 ? 14 : 24
    readonly property string omiImage: theme.isDark
                                         ? "qrc:/FilterDesigner/icons/shadcy-for-black-bg.png"
                                         : "qrc:/FilterDesigner/icons/shadcy-for-white-bg.png"
    property string approveModeText: "Approve for me"

    function readableMath(source) {
        let s = source
        const commands = {
            "\\alpha":"α", "\\beta":"β", "\\gamma":"γ", "\\delta":"δ",
            "\\epsilon":"ε", "\\theta":"θ", "\\lambda":"λ", "\\mu":"μ",
            "\\omega":"ω", "\\Omega":"Ω", "\\phi":"φ", "\\pi":"π",
            "\\sigma":"σ", "\\tau":"τ", "\\zeta":"ζ", "\\Delta":"Δ",
            "\\cdot":"·", "\\times":"×", "\\approx":"≈", "\\leq":"≤",
            "\\geq":"≥", "\\infty":"∞", "\\pm":"±", "\\rightarrow":"→",
            "\\left":"", "\\right":"", "\\mathrm":"", "\\text":""
        }
        for (const key in commands) s = s.split(key).join(commands[key])
        s = s.replace(/\\frac\s*\{([^{}]+)\}\s*\{([^{}]+)\}/g, "($1)/($2)")
             .replace(/\\sqrt\s*\{([^{}]+)\}/g, "√($1)")
             .replace(/\^\{?2\}?/g, "²").replace(/\^\{?3\}?/g, "³")
             .replace(/\^\{?(-?\d)\}?/g, "^$1")
             .replace(/_\{?([a-zA-Z0-9]+)\}?/g, "₍$1₎")
             .replace(/[{}]/g, "")
        return s
    }

    function readableMarkdown(source) {
        let result = source.replace(/\$\$([\s\S]+?)\$\$/g, function(_, math) {
            return "\n\n`" + root.readableMath(math) + "`\n\n"
        })
        result = result.replace(/\\\[([\s\S]+?)\\\]/g, function(_, math) {
            return "\n\n`" + root.readableMath(math) + "`\n\n"
        })
        result = result.replace(/\\\((.+?)\\\)/g, function(_, math) {
            return "`" + root.readableMath(math) + "`"
        })
        return result.replace(/\$([^$\n]+)\$/g, function(_, math) {
            return "`" + root.readableMath(math) + "`"
        })
    }

    Rectangle { anchors.fill: parent; color: theme.background }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.pageMargin
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Image {
                source: root.omiImage
                sourceSize.width: 56
                sourceSize.height: 56
                fillMode: Image.PreserveAspectFit
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
            }
            Text {
                text: "Omi"
                color: theme.primaryText
                font.family: theme.headlineFont
                font.pixelSize: 19
                font.weight: Font.DemiBold
                Layout.fillWidth: true
            }
            Text {
                text: chat.modelName.length ? chat.modelName : "No model selected"
                color: theme.secondaryText
                font.family: theme.bodyFont
                font.pixelSize: 12
                elide: Text.ElideMiddle
                Layout.maximumWidth: 220
            }
            StyledButton {
                text: "Settings"
                primary: false
                onClicked: {
                    const w = Window.window
                    if (w && typeof w.navigateTo === "function") w.navigateTo(6)
                }
            }
            StyledButton {
                text: "Clear"
                primary: false
                enabled: !chat.busy && chat.messages.length > 0
                onClicked: chat.clearConversation()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: theme.borderColor
            opacity: 0.7
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                visible: chat.messages.length === 0
                spacing: 12
                Item { Layout.fillHeight: true }
                Image {
                    source: root.omiImage
                    sourceSize.width: 192
                    sourceSize.height: 144
                    fillMode: Image.PreserveAspectFit
                    Layout.preferredWidth: 112
                    Layout.preferredHeight: 84
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: "Ask about the active design"
                    color: theme.primaryText
                    font.family: theme.headlineFont
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    visible: !chat.modelName.length || !chat.apiKeyConfigured
                    text: !chat.modelName.length ? "Choose a model and add an OpenRouter key in Settings" : "Add an OpenRouter key in Settings"
                    color: theme.secondaryText
                    font.family: theme.bodyFont
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: Math.min(parent.width, 460)
                    Layout.alignment: Qt.AlignHCenter
                }
                Flow {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: Math.min(parent.width, 760)
                    spacing: 7
                    Repeater {
                        model: ["Explain the active response", "Plot the phase response", "Show impulse and step response"]
                        delegate: StyledButton {
                            required property string modelData
                            text: modelData
                            primary: false
                            onClicked: { prompt.text = modelData; prompt.forceActiveFocus() }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            ListView {
                id: thread
                anchors.fill: parent
                visible: chat.messages.length > 0
                clip: true
                spacing: 18
                model: chat.messages
                boundsBehavior: Flickable.StopAtBounds
                onCountChanged: Qt.callLater(positionViewAtEnd)

                delegate: Item {
                    required property var modelData
                    width: thread.width
                    height: messageColumn.implicitHeight

                    Column {
                        id: messageColumn
                        width: Math.min(parent.width, root.width < 680 ? parent.width : 860)
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        Row {
                            visible: modelData.role === "assistant"
                            spacing: 8
                            Image {
                                source: root.omiImage
                                sourceSize.width: 48
                                sourceSize.height: 48
                                fillMode: Image.PreserveAspectFit
                                width: 30
                                height: 26
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Omi"
                                color: theme.secondaryText
                                font.family: theme.headlineFont
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Rectangle {
                            visible: modelData.role === "user"
                            width: Math.min(parent.width, userText.implicitWidth + 28)
                            height: userText.implicitHeight + 22
                            anchors.right: parent.right
                            radius: 8
                            color: theme.surfaceHigh
                            Text {
                                id: userText
                                anchors.fill: parent
                                anchors.margins: 11
                                text: modelData.content
                                color: theme.primaryText
                                font.family: theme.bodyFont
                                font.pixelSize: 14
                                wrapMode: Text.Wrap
                            }
                        }

                        Text {
                            visible: modelData.role === "assistant"
                            width: parent.width
                            text: root.readableMarkdown(modelData.content)
                            textFormat: Text.MarkdownText
                            color: theme.primaryText
                            font.family: theme.bodyFont
                            font.pixelSize: 14
                            wrapMode: Text.Wrap
                            lineHeight: 1.28
                            onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                        }

                        ChatPlot {
                            visible: modelData.role === "assistant" && modelData.artifacts && modelData.artifacts.length > 0
                            width: parent.width
                            height: visible ? 310 : 0
                            artifacts: modelData.artifacts || []
                            mode: modelData.plotMode >= 0 ? modelData.plotMode : 0
                        }
                    }
                }
            }
        }

        Rectangle {
            id: promptContainer
            Layout.fillWidth: true
            Layout.maximumWidth: 920
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: promptColumn.implicitHeight + 24
            radius: 18
            color: theme.isDark ? "#242426" : "#F5F5F7"
            border.color: prompt.activeFocus ? theme.accent : (theme.isDark ? "#36363A" : "#DCDCDE")
            border.width: prompt.activeFocus ? 1.5 : 1

            ColumnLayout {
                id: promptColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    visible: chat.busy
                    text: "Calculating from DSP artifacts…"
                    color: theme.secondaryText
                    font.family: theme.bodyFont
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }

                TextArea {
                    id: prompt
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 38
                    Layout.maximumHeight: 90
                    placeholderText: "Do anything"
                    color: theme.primaryText
                    placeholderTextColor: theme.isDark ? "#7A7A7E" : "#8E8E93"
                    selectedTextColor: "#FFFFFF"
                    selectionColor: theme.accent
                    font.family: theme.bodyFont
                    font.pixelSize: 15
                    wrapMode: TextEdit.Wrap
                    background: Item {}
                    Keys.onReturnPressed: function(event) {
                        if (!(event.modifiers & Qt.ShiftModifier)) {
                            event.accepted = true
                            root.sendPrompt()
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // ── Left Side: Plus icon & Approve mode pill ──
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: plusHov.hovered ? (theme.isDark ? "#343438" : "#E4E4E8") : "transparent"

                        Codicon {
                            anchors.centerIn: parent
                            icon: "add"
                            iconSize: 16
                            iconColor: theme.isDark ? "#D0D0D4" : "#48484A"
                        }

                        HoverHandler { id: plusHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: attachMenu.open() }

                        Menu {
                            id: attachMenu
                            MenuItem {
                                text: "Include Active Filter Context"
                                onClicked: prompt.text += (prompt.text.length ? " " : "") + "[Context: Active filter design specifications]"
                            }
                            MenuItem {
                                text: "Explain Magnitude & Phase Response"
                                onClicked: { prompt.text = "Explain the magnitude and phase response of the current filter design."; root.sendPrompt() }
                            }
                            MenuItem {
                                text: "Analyze Pole-Zero Stability"
                                onClicked: { prompt.text = "Analyze the pole-zero placement, stability margins, and Q factors."; root.sendPrompt() }
                            }
                            MenuItem {
                                text: "Show Impulse & Step Response"
                                onClicked: { prompt.text = "Evaluate the transient impulse and step response in the time domain."; root.sendPrompt() }
                            }
                        }
                    }

                    Rectangle {
                        height: 28
                        implicitWidth: approveRow.implicitWidth + 18
                        radius: 14
                        color: approveHov.hovered ? (theme.isDark ? "#343438" : "#E4E4E8") : "transparent"

                        Row {
                            id: approveRow
                            anchors.centerIn: parent
                            spacing: 6

                            Codicon {
                                icon: "smiley"
                                iconSize: 14
                                iconColor: theme.isDark ? "#D0D0D4" : "#3A3A3C"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.approveModeText
                                color: theme.isDark ? "#D0D0D4" : "#3A3A3C"
                                font.family: theme.bodyFont
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler { id: approveHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: approveMenu.open() }

                        Menu {
                            id: approveMenu
                            MenuItem {
                                text: "Approve for me"
                                onClicked: root.approveModeText = "Approve for me"
                            }
                            MenuItem {
                                text: "Auto-run DSP variations"
                                onClicked: root.approveModeText = "Auto-run DSP"
                            }
                            MenuItem {
                                text: "Ask before running"
                                onClicked: root.approveModeText = "Ask before running"
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // ── Right Side: Model dropdown, Mic button, Blue Action Circle ──
                    Rectangle {
                        height: 28
                        implicitWidth: modelRow.implicitWidth + 18
                        radius: 14
                        color: modelHov.hovered ? (theme.isDark ? "#343438" : "#E4E4E8") : "transparent"

                        Row {
                            id: modelRow
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                text: chat.modelName.length ? chat.modelName : "google/gemini-2.0-flash-001"
                                color: theme.isDark ? "#D0D0D4" : "#3A3A3C"
                                font.family: theme.bodyFont
                                font.pixelSize: 13
                                font.weight: Font.SemiBold
                                elide: Text.ElideRight
                                Layout.maximumWidth: 160
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Codicon {
                                icon: "chevron-down"
                                iconSize: 11
                                iconColor: theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler { id: modelHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: modelMenu.open() }

                        Menu {
                            id: modelMenu
                            MenuItem {
                                text: "google/gemini-2.0-flash-001 (Recommended)"
                                onClicked: chat.modelName = "google/gemini-2.0-flash-001"
                            }
                            MenuItem {
                                text: "anthropic/claude-3.5-sonnet"
                                onClicked: chat.modelName = "anthropic/claude-3.5-sonnet"
                            }
                            MenuItem {
                                text: "openai/gpt-4o"
                                onClicked: chat.modelName = "openai/gpt-4o"
                            }
                            MenuItem {
                                text: "deepseek/deepseek-chat"
                                onClicked: chat.modelName = "deepseek/deepseek-chat"
                            }
                            MenuItem {
                                text: "meta-llama/llama-3.3-70b-instruct"
                                onClicked: chat.modelName = "meta-llama/llama-3.3-70b-instruct"
                            }
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: micHov.hovered ? (theme.isDark ? "#343438" : "#E4E4E8") : "transparent"

                        Codicon {
                            anchors.centerIn: parent
                            icon: "mic"
                            iconSize: 16
                            iconColor: theme.isDark ? "#D0D0D4" : "#48484A"
                        }

                        HoverHandler { id: micHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                const w = Window.window
                                if (w && typeof w.showNotification === "function")
                                    w.showNotification("Microphone input toggled", false)
                            }
                        }
                    }

                    // Blue circular action button (Send / Stop)
                    Rectangle {
                        id: actionBtn
                        width: 32
                        height: 32
                        radius: 16
                        color: sendHov.pressed ? "#1d4ed8" : (sendHov.hovered ? "#3b82f6" : "#2563eb")

                        Item {
                            anchors.centerIn: parent
                            width: 16
                            height: 16

                            // Stop icon square (when busy)
                            Rectangle {
                                visible: chat.busy
                                anchors.centerIn: parent
                                width: 11
                                height: 11
                                radius: 2
                                color: "#FFFFFF"
                            }

                            // Arrow up icon (when idle)
                            Codicon {
                                visible: !chat.busy
                                anchors.centerIn: parent
                                icon: "arrow-up"
                                iconSize: 15
                                iconColor: "#FFFFFF"
                            }
                        }

                        HoverHandler { id: sendHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler {
                            onTapped: {
                                if (chat.busy) {
                                    if (typeof chat.cancelRequest === "function") chat.cancelRequest()
                                } else {
                                    root.sendPrompt()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function sendPrompt() {
        const text = prompt.text.trim()
        if (!text.length) return
        chat.sendMessage(text)
        prompt.clear()
    }

    Connections {
        target: chat
        function onRequestFailed(message) {
            const w = Window.window
            if (w && typeof w.showNotification === "function") w.showNotification(message, true)
        }
    }
}

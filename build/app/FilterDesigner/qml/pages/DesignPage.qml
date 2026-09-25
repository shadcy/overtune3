import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// DesignPage.qml — Filter configuration + live frequency response (overflow-safe)
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property var typeNames:     ["Low Pass", "High Pass", "Band Pass", "Band Stop"]
    readonly property var responseNames: ["Butterworth", "Chebyshev I", "Chebyshev II", "Elliptic", "Bessel"]
    readonly property bool isBand: filterEngine.filterType >= 2
    readonly property bool narrowLayout: width < 900
    readonly property int pageMargin: width < 700 ? 10 : 16

    function setPlotMode(m) {
        if (freqPlot) freqPlot.displayMode = m
    }

    readonly property real configWidth: {
        const w = Math.min(340, Math.max(240, width * 0.3))
        return Math.min(w, Math.max(200, width - 280))
    }

    readonly property real configHeight: {
        const minPlot = 160
        const budget = Math.max(140, height - minPlot - pageMargin)
        return Math.min(budget, Math.max(160, Math.min(360, height * 0.4)))
    }

    // ── Config panel ──────────────────────────────────────────────────────────
    Item {
        id: configPanel
        x: 0
        y: 0
        width: root.narrowLayout ? root.width : root.configWidth
        height: root.narrowLayout ? root.configHeight : root.height
        z: 1
        clip: true

        Rectangle {
            anchors.fill: parent
            color: theme.sidebarBg
        }

        Rectangle {
            id: titleStrip
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 35
            color: "transparent"
            z: 2

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 14
                }
                text: "OVERTUNE 3"
                font.family: "Stack Sans Headline"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.letterSpacing: 0.6
                color: theme.secondaryText
                elide: Text.ElideRight
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.borderColor
                opacity: 0.55
            }
        }

        Flickable {
            id: configFlick
            anchors {
                top: titleStrip.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            clip: true
            contentWidth: width
            contentHeight: configColumn.implicitHeight + 24
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar {
                policy: configFlick.contentHeight > configFlick.height
                        ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: configColumn
                x: 12
                width: Math.max(0, configFlick.width - 24)
                spacing: 6
                topPadding: 10
                bottomPadding: 16

                Text {
                    width: parent.width
                    text: "Filter Configuration"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: theme.primaryText
                    wrapMode: Text.WordWrap
                }

                SectionHeader { text: "TYPE"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Topology"
                    StyledCombo {
                        width: parent.width
                        model: root.typeNames
                        currentIndex: filterEngine.filterType
                        onActivated: filterEngine.filterType = currentIndex
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: "Response"
                    StyledCombo {
                        width: parent.width
                        model: root.responseNames
                        currentIndex: filterEngine.filterResponse
                        onActivated: filterEngine.filterResponse = currentIndex
                    }
                }

                Item { width: 1; height: 4 }
                SectionHeader { text: "PARAMETERS"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Order"
                    StyledSlider {
                        width: parent.width
                        from: 1
                        to: filterEngine.filterResponse === 4 ? 10 : 16
                        value: filterEngine.order
                        stepSize: 1
                        valueDecimals: 0
                        onMoved: filterEngine.order = Math.round(value)
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: "Sample Rate"
                    StyledCombo {
                        width: parent.width
                        model: ["8000", "22050", "44100", "48000", "96000", "192000"]
                        currentIndex: {
                            const rates = [8000, 22050, 44100, 48000, 96000, 192000]
                            const i = rates.indexOf(Math.round(filterEngine.sampleRate))
                            return i >= 0 ? i : 3
                        }
                        onActivated: filterEngine.sampleRate = parseFloat(model[currentIndex])
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: root.isBand ? "Fc Low" : "Cutoff"
                    StyledSlider {
                        width: parent.width
                        from: 10
                        to: Math.max(20, filterEngine.sampleRate / 2 - 1)
                        value: Math.min(filterEngine.cutoffFreq, filterEngine.sampleRate / 2 - 1)
                        stepSize: 1
                        valueSuffix: " Hz"
                        valueDecimals: 0
                        onMoved: filterEngine.cutoffFreq = value
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: root.isBand
                    height: visible ? implicitHeight : 0
                    opacity: visible ? 1 : 0
                    label: "Fc High"
                    StyledSlider {
                        width: parent.width
                        from: Math.min(filterEngine.cutoffFreq + 10, filterEngine.sampleRate / 2 - 2)
                        to: Math.max(filterEngine.cutoffFreq + 20, filterEngine.sampleRate / 2 - 1)
                        value: Math.max(filterEngine.cutoffFreq2, filterEngine.cutoffFreq + 10)
                        stepSize: 1
                        valueSuffix: " Hz"
                        valueDecimals: 0
                        onMoved: filterEngine.cutoffFreq2 = value
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: filterEngine.filterResponse === 1 || filterEngine.filterResponse === 3
                    height: visible ? implicitHeight : 0
                    label: "Ripple"
                    StyledSlider {
                        width: parent.width
                        from: 0.1
                        to: 5.0
                        value: filterEngine.rippleDb
                        stepSize: 0.1
                        valueSuffix: " dB"
                        valueDecimals: 1
                        onMoved: filterEngine.rippleDb = value
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: filterEngine.filterResponse === 2 || filterEngine.filterResponse === 3
                    height: visible ? implicitHeight : 0
                    label: "Stopband"
                    StyledSlider {
                        width: parent.width
                        from: 20
                        to: 120
                        value: filterEngine.stopbandDb
                        stepSize: 1
                        valueSuffix: " dB"
                        valueDecimals: 0
                        onMoved: filterEngine.stopbandDb = value
                    }
                }

                Item { width: 1; height: 8 }
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.borderColor
                    opacity: 0.5
                }
                Item { width: 1; height: 6 }

                Text {
                    width: parent.width
                    text: filterEngine.filterResponseName() + " " + filterEngine.filterTypeName()
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: theme.primaryText
                    wrapMode: Text.WordWrap
                }
                Text {
                    width: parent.width
                    text: "Order " + filterEngine.order + "  ·  Fs = " +
                          Number(filterEngine.sampleRate).toLocaleString(Qt.locale(), "f", 0) + " Hz"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 12
                    color: theme.secondaryText
                    wrapMode: Text.WordWrap
                }
            }
        }

        Rectangle {
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 1
            color: theme.borderColor
            opacity: 0.55
            visible: !root.narrowLayout
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: theme.borderColor
            opacity: 0.55
            visible: root.narrowLayout
        }
    }

    // ── Plot area: unified workbench card ─────────────────────────────────────
    Rectangle {
        id: plotArea
        anchors {
            left: root.narrowLayout ? parent.left : configPanel.right
            top: root.narrowLayout ? configPanel.bottom : parent.top
            right: parent.right
            bottom: parent.bottom
            margins: root.pageMargin
        }
        color: theme.surface
        radius: 8
        border.color: theme.borderColor
        border.width: 1
        clip: true

        // Sticky VS Code Editor Tab Bar (seamlessly integrated into top of card)
        Rectangle {
            id: stickyTabBar
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 38
            color: theme.isDark ? "#252526" : "#F3F3F3"
            z: 10

            // 1px horizontal separator line between tabs and plot
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: theme.borderColor
            }

            Row {
                id: tabRow
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: [
                        { label: "Magnitude",   unit: "dB",      icon: "graph" },
                        { label: "Phase",       unit: "°",       icon: "pulse" },
                        { label: "Group Delay", unit: "samples", icon: "history" }
                    ]
                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        readonly property bool active: freqPlot.displayMode === index
                        width: Math.max(90, tabContent.implicitWidth + 24)
                        height: stickyTabBar.height
                        color: active
                            ? (theme.isDark ? "#1E1E1E" : "#FFFFFF")
                            : (tabHov.hovered ? (theme.isDark ? "#2A2D2E" : "#E8E8E8") : "transparent")

                        // Active blue top indicator bar (VS Code tab style)
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 2
                            color: theme.accent
                            visible: parent.active
                        }

                        // Right vertical divider
                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 1
                            color: theme.borderColor
                            visible: !parent.active
                        }

                        Row {
                            id: tabContent
                            anchors.centerIn: parent
                            spacing: 6

                            Codicon {
                                icon: modelData.icon
                                iconSize: 14
                                iconColor: parent.parent.active ? theme.accent : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.label
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 12
                                font.weight: parent.parent.active ? Font.DemiBold : Font.Normal
                                color: parent.parent.active ? theme.primaryText : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Unit pill badge
                            Rectangle {
                                width: unitText.implicitWidth + 8
                                height: 16
                                radius: 4
                                color: parent.parent.active
                                    ? (theme.isDark ? "#2D2D2D" : "#EAEAEA")
                                    : (theme.isDark ? "#1E1E1E" : "#DFDFDF")
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: unitText
                                    anchors.centerIn: parent
                                    text: modelData.unit
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 10
                                    color: theme.secondaryText
                                }
                            }
                        }

                        HoverHandler {
                            id: tabHov
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: freqPlot.displayMode = index
                        }
                    }
                }
            }

            // Real-time readout metric on the right of sticky bar
            Row {
                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                spacing: 8
                visible: stickyTabBar.width > 560

                Text {
                    text: {
                        if (freqPlot.displayMode === 0)
                            return "Cutoff: " + Number(filterEngine.cutoffFreq).toLocaleString(Qt.locale(), "f", 0) + " Hz  ·  -3.0 dB"
                        else if (freqPlot.displayMode === 1)
                            return "Order: " + filterEngine.order + "  ·  Unwrapped Phase"
                        else
                            return "Fs: " + Number(filterEngine.sampleRate).toLocaleString(Qt.locale(), "f", 0) + " Hz  ·  Exact τg"
                    }
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    color: theme.secondaryText
                }
            }
        }

        // Plot canvas connected seamlessly below sticky tab bar
        FrequencyPlot {
            id: freqPlot
            anchors {
                left: parent.left
                right: parent.right
                top: stickyTabBar.bottom
                bottom: parent.bottom
            }
        }
    }
}

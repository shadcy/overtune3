import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

// DocsPage.qml — VS Code–style welcome / documentation hub
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property int pageMargin: width < 700 ? 12 : 24
    readonly property bool narrow: width < 860

    function go(pageIndex) {
        const w = Window.window
        if (w && typeof w.navigateTo === "function")
            w.navigateTo(pageIndex)
    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: root.pageMargin
        clip: true
        contentWidth: width
        contentHeight: mainCol.implicitHeight + 32
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar {
            policy: flick.contentHeight > flick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }

        Column {
            id: mainCol
            width: flick.width
            spacing: 28

            // Hero
            Column {
                width: parent.width
                spacing: 8

                Row {
                    spacing: 12
                    Codicon {
                        icon: "book"
                        iconSize: 28
                        iconColor: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Overtune 3"
                        font.family: "Inter"
                        font.pixelSize: root.narrow ? 22 : 28
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Text {
                    width: Math.min(parent.width, 640)
                    text: "Design IIR filters, inspect responses, simulate signals, and export production-ready code. Use the activity bar or the links below to move through the workflow."
                    font.family: "Inter"
                    font.pixelSize: 14
                    color: theme.secondaryText
                    wrapMode: Text.WordWrap
                    lineHeight: 1.35
                }
            }

            // Start
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "Start"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.4
                    color: theme.secondaryText
                }

                GridLayout {
                    width: parent.width
                    columns: root.narrow ? 1 : 2
                    rowSpacing: 10
                    columnSpacing: 10

                    Repeater {
                        model: [
                            {
                                title: "Design a filter",
                                body: "Choose topology, response, order, and cutoff. Drag Fc on the magnitude plot.",
                                icon: "tools",
                                page: 0
                            },
                            {
                                title: "Inspect analysis",
                                body: "Magnitude, phase, group delay, pole-zero, impulse, and step responses.",
                                icon: "graph",
                                page: 1
                            },
                            {
                                title: "Run a simulation",
                                body: "Load WAV/CSV or generate sine/chirp, then apply the current filter.",
                                icon: "play",
                                page: 2
                            },
                            {
                                title: "Export coefficients",
                                body: "Generate C, C++ header, Python, or JSON for your DSP pipeline.",
                                icon: "export",
                                page: 3
                            }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: cardCol.implicitHeight + 28
                            radius: 10
                            color: theme.surface
                            border.color: cardHov.hovered ? theme.accent : theme.borderColor
                            border.width: 1
                            clip: true

                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Column {
                                id: cardCol
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 14
                                }
                                spacing: 8

                                Row {
                                    spacing: 10
                                    width: parent.width
                                    Codicon {
                                        icon: modelData.icon
                                        iconSize: 18
                                        iconColor: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.title
                                        font.family: "Inter"
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        color: theme.primaryText
                                        elide: Text.ElideRight
                                        width: Math.max(0, parent.width - 40)
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.body
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: theme.secondaryText
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.3
                                }
                                Row {
                                    spacing: 6
                                    Text {
                                        text: "Open"
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: theme.accent
                                    }
                                    Codicon {
                                        icon: "arrow-right"
                                        iconSize: 12
                                        iconColor: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            HoverHandler { id: cardHov }
                            TapHandler { onTapped: root.go(modelData.page) }
                        }
                    }
                }
            }

            // Learn
            Column {
                width: parent.width
                spacing: 12

                Text {
                    text: "Learn"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.4
                    color: theme.secondaryText
                }

                Column {
                    width: Math.min(parent.width, 720)
                    spacing: 2

                    Repeater {
                        model: [
                            {
                                title: "Filter topologies",
                                body: "Low-pass, high-pass, band-pass, and band-stop. Band designs use Fc Low and Fc High.",
                                icon: "filter"
                            },
                            {
                                title: "Response families",
                                body: "Butterworth (maximally flat), Chebyshev I/II (ripple trade-offs), Elliptic (steepest), Bessel (linear phase).",
                                icon: "pulse"
                            },
                            {
                                title: "Reading the plots",
                                body: "Magnitude in dB, phase in degrees, group delay in samples. Poles (×) and zeros (○) on the z-plane.",
                                icon: "graph"
                            },
                            {
                                title: "Export formats",
                                body: "C (Direct Form II Transposed SOS), C++ constexpr header, Python sosfilt snippet, and JSON metadata.",
                                icon: "desktop-download"
                            },
                            {
                                title: "Appearance",
                                body: "Switch System / Light / Dark under Settings. Charts and chrome follow the active theme.",
                                icon: "settings-gear",
                                page: 5
                            }
                        ]
                        delegate: Item {
                            required property var modelData
                            width: parent.width
                            height: learnRow.implicitHeight + 16

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: learnHov.hovered ? theme.surfaceHigh : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }

                            Row {
                                id: learnRow
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 8
                                    rightMargin: 8
                                }
                                spacing: 12

                                Codicon {
                                    icon: modelData.icon
                                    iconSize: 16
                                    iconColor: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Column {
                                    width: Math.max(0, learnRow.width - 50)
                                    spacing: 2
                                    Text {
                                        width: parent.width
                                        text: modelData.title
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: theme.primaryText
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        width: parent.width
                                        text: modelData.body
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        color: theme.secondaryText
                                        wrapMode: Text.WordWrap
                                    }
                                }
                                Codicon {
                                    visible: modelData.page !== undefined
                                    icon: "chevron-right"
                                    iconSize: 14
                                    iconColor: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            HoverHandler { id: learnHov }
                            TapHandler {
                                enabled: modelData.page !== undefined
                                onTapped: root.go(modelData.page)
                            }
                        }
                    }
                }
            }

            // Footer tip
            Rectangle {
                width: Math.min(parent.width, 720)
                height: tipCol.implicitHeight + 24
                radius: 10
                color: theme.accentMuted
                border.color: theme.accent
                border.width: 1
                opacity: 0.95

                Row {
                    id: tipCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: 14
                    }
                    spacing: 12

                    Codicon {
                        icon: "lightbulb"
                        iconSize: 18
                        iconColor: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        width: Math.max(0, tipCol.width - 40)
                        text: "Tip: On the Design plot, drag the blue cutoff handle to retune Fc in real time. Band filters also show a green Fc High handle."
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: theme.primaryText
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}

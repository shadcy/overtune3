import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

// SettingsPage.qml — scrollable, overflow-safe settings
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property int pageMargin: width < 700 ? 12 : 20
    readonly property real cardMax: 520

    function openDocs() {
        const w = Window.window
        if (w && typeof w.navigateTo === "function")
            w.navigateTo(4)
    }

    component AboutRow: Item {
        id: rowRoot
        property string label: ""
        property string value: ""
        property bool stack: width < 340
        width: parent ? parent.width : 200
        height: stack ? (lab.implicitHeight + val.implicitHeight + 6) : Math.max(lab.implicitHeight, val.implicitHeight)

        Text {
            id: lab
            text: rowRoot.label
            font.family: "Stack Sans Headline"
            font.pixelSize: 13
            color: theme.secondaryText
            width: rowRoot.stack ? rowRoot.width : Math.min(130, rowRoot.width * 0.34)
            wrapMode: Text.WordWrap
        }
        Text {
            id: val
            text: rowRoot.value
            font.family: "Stack Sans Headline"
            font.pixelSize: 13
            color: theme.primaryText
            wrapMode: Text.WordWrap
            anchors {
                left: rowRoot.stack ? parent.left : lab.right
                leftMargin: rowRoot.stack ? 0 : 10
                top: rowRoot.stack ? lab.bottom : parent.top
                topMargin: rowRoot.stack ? 2 : 0
                right: parent.right
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: root.pageMargin
        clip: true
        contentWidth: width
        contentHeight: contentCol.implicitHeight + 24
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        ScrollBar.vertical: ScrollBar {
            policy: flick.contentHeight > flick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }

        Column {
            id: contentCol
            width: Math.min(root.cardMax, flick.width)
            spacing: 16

            Text {
                width: parent.width
                text: "Settings"
                font.family: "Stack Sans Headline"
                font.pixelSize: root.width < 500 ? 20 : 24
                font.weight: Font.DemiBold
                color: theme.primaryText
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width
                implicitHeight: appearanceCol.implicitHeight + 32
                height: implicitHeight
                radius: 12
                color: theme.surface
                border.color: theme.borderColor
                border.width: 1
                clip: true

                Column {
                    id: appearanceCol
                    anchors { fill: parent; margins: 16 }
                    spacing: 10
                    width: parent.width - 32

                    SectionHeader { text: "APPEARANCE"; width: parent.width }

                    Repeater {
                        model: [
                            { label: "System", value: 0 },
                            { label: "Light",  value: 1 },
                            { label: "Dark",   value: 2 }
                        ]
                        delegate: Item {
                            required property var modelData
                            width: appearanceCol.width
                            height: 30

                            Rectangle {
                                id: radio
                                width: 18; height: 18
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                border.color: theme.accent
                                border.width: selected ? 0 : 1.5
                                color: selected ? theme.accent : "transparent"
                                readonly property bool selected: theme.themeMode === modelData.value
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: "#FFFFFF"
                                    anchors.centerIn: parent
                                    visible: parent.selected
                                }
                            }
                            Text {
                                anchors {
                                    left: radio.right
                                    leftMargin: 12
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }
                                text: modelData.label
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 14
                                color: theme.primaryText
                                elide: Text.ElideRight
                            }
                            TapHandler { onTapped: theme.themeMode = modelData.value }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                implicitHeight: aboutCol.implicitHeight + 32
                height: implicitHeight
                radius: 12
                color: theme.surface
                border.color: theme.borderColor
                border.width: 1
                clip: true

                Column {
                    id: aboutCol
                    anchors { fill: parent; margins: 16 }
                    spacing: 12
                    width: parent.width - 32

                    SectionHeader { text: "ABOUT"; width: parent.width }

                    AboutRow { label: "Application"; value: "Overtune 3"; width: parent.width }
                    AboutRow { label: "Version"; value: "3.0.0"; width: parent.width }
                    AboutRow { label: "DSP Engine"; value: "Pure C++20 — no external DSP deps"; width: parent.width }
                    AboutRow { label: "UI"; value: "Qt 6 / QML · Inter · Codicons"; width: parent.width }
                    AboutRow { label: "Fonts"; value: "Inter (OFL) · Codicons (CC-BY 4.0)"; width: parent.width }
                }
            }

            Rectangle {
                width: parent.width
                height: 72
                radius: 12
                color: theme.surface
                border.color: theme.borderColor
                border.width: 1
                clip: true

                Codicon {
                    id: docsIcon
                    anchors {
                        left: parent.left
                        leftMargin: 16
                        verticalCenter: parent.verticalCenter
                    }
                    icon: "book"
                    iconSize: 20
                    iconColor: theme.accent
                }

                Column {
                    anchors {
                        left: docsIcon.right
                        leftMargin: 12
                        right: openDocsBtn.left
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 2
                    Text {
                        width: parent.width
                        text: "Documentation"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: "Guides, filter types, and workflow tips"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.secondaryText
                        elide: Text.ElideRight
                    }
                }

                StyledButton {
                    id: openDocsBtn
                    anchors {
                        right: parent.right
                        rightMargin: 14
                        verticalCenter: parent.verticalCenter
                    }
                    text: "Open"
                    primary: false
                    implicitWidth: 64
                    implicitHeight: 28
                    onClicked: root.openDocs()
                }
            }
        }
    }
}

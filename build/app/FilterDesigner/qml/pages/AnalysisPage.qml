import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// AnalysisPage.qml — Full analysis suite (scrolls when stacked)
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property bool narrowLayout: width < 860
    readonly property int pageMargin: width < 700 ? 10 : 16
    readonly property real cardMinH: narrowLayout ? 240 : 180

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: root.pageMargin
        clip: true
        contentWidth: width
        contentHeight: root.narrowLayout ? grid.implicitHeight : height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: root.narrowLayout ? Flickable.VerticalFlick : Flickable.AutoFlickIfNeeded
        interactive: root.narrowLayout
        ScrollBar.vertical: ScrollBar {
            policy: root.narrowLayout && flick.contentHeight > flick.height
                    ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }

        GridLayout {
            id: grid
            width: flick.width
            height: root.narrowLayout ? implicitHeight : flick.height
            columns: root.narrowLayout ? 1 : 2
            rowSpacing: 10
            columnSpacing: 10

            // Magnitude
            FilterCard {
                Layout.fillWidth: true
                Layout.fillHeight: !root.narrowLayout
                Layout.preferredHeight: root.narrowLayout ? root.cardMinH : -1
                Layout.minimumHeight: root.cardMinH
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    Text {
                        text: "Magnitude (dB)"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    FrequencyPlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        displayMode: 0
                    }
                }
            }

            // Phase
            FilterCard {
                Layout.fillWidth: true
                Layout.fillHeight: !root.narrowLayout
                Layout.preferredHeight: root.narrowLayout ? root.cardMinH : -1
                Layout.minimumHeight: root.cardMinH
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    Text {
                        text: "Phase (°)"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    FrequencyPlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        displayMode: 1
                    }
                }
            }

            // Group delay
            FilterCard {
                Layout.fillWidth: true
                Layout.fillHeight: !root.narrowLayout
                Layout.preferredHeight: root.narrowLayout ? root.cardMinH : -1
                Layout.minimumHeight: root.cardMinH
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6
                    Text {
                        text: "Group Delay (samples)"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    FrequencyPlot {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        displayMode: 2
                    }
                }
            }

            // Pole-zero / impulse / step
            FilterCard {
                Layout.fillWidth: true
                Layout.fillHeight: !root.narrowLayout
                Layout.preferredHeight: root.narrowLayout ? 280 : -1
                Layout.minimumHeight: 200
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    Text {
                        text: "Time / Pole-Zero"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 26
                        spacing: 4

                        Repeater {
                            model: ["Pole-Zero", "Impulse", "Step"]
                            delegate: StyledButton {
                                required property int index
                                required property string modelData
                                text: modelData
                                primary: stackView.currentIndex === index
                                Layout.fillWidth: true
                                Layout.minimumWidth: 56
                                Layout.preferredHeight: 24
                                font.pixelSize: 11
                                onClicked: stackView.currentIndex = index
                            }
                        }
                    }

                    StackLayout {
                        id: stackView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 120
                        currentIndex: 0

                        PoleZeroPlot { Layout.fillWidth: true; Layout.fillHeight: true }
                        ImpulseStepPlot { Layout.fillWidth: true; Layout.fillHeight: true; mode: 0 }
                        ImpulseStepPlot { Layout.fillWidth: true; Layout.fillHeight: true; mode: 1 }
                    }
                }
            }
        }
    }
}

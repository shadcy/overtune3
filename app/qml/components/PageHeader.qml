import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// PageHeader.qml — Consistent, clean page headline bar across all tabs without subtitles
Item {
    id: root
    width: parent ? parent.width : 800
    implicitHeight: Math.max(headerRow.implicitHeight + 10, 42)
    height: implicitHeight

    property string title: ""
    property string badgeText: ""
    property string badgeIcon: ""
    property color badgeColor: theme.accent
    property bool badgeVisible: badgeText.length > 0

    default property alias actions: actionsRow.children

    readonly property bool isNarrow: width < 720

    Item {
        anchors.fill: parent

        RowLayout {
            id: headerRow
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: 16

            // Left: Title
            Text {
                id: titleText
                text: root.title
                font.family: "Stack Sans Headline"
                font.pixelSize: root.isNarrow ? 18 : 20
                font.weight: Font.DemiBold
                color: theme.primaryText
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            // Right: Filter/Status Badge & Extra Action Buttons
            Row {
                id: rightSideRow
                Layout.alignment: Qt.AlignVCenter
                spacing: 10

                // Status Badge Pill
                Rectangle {
                    id: badgePill
                    visible: root.badgeVisible
                    implicitHeight: 28
                    implicitWidth: badgeContentRow.implicitWidth + 18
                    radius: 6
                    color: theme.surfaceHigh
                    border.color: theme.borderColor
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Row {
                        id: badgeContentRow
                        anchors.centerIn: parent
                        spacing: 7

                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            color: root.badgeColor
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Codicon {
                            visible: root.badgeIcon.length > 0
                            icon: root.badgeIcon
                            iconSize: 12
                            iconColor: theme.secondaryText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.badgeText
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: theme.primaryText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Injected Actions
                Row {
                    id: actionsRow
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Bottom divider line
        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: theme.borderColor
            opacity: 0.5
        }
    }
}

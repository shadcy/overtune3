import QtQuick
import QtQuick.Controls

// SegmentedButton.qml — Modern segmented button group with smooth indicator animation
Item {
    id: root
    implicitHeight: 28
    implicitWidth: Math.max(200, (root.model ? root.model.length : 1) * 64)
    clip: true

    property var model: [] // Array of string ["Tab 1", "Tab 2"] or objects [{label: "...", icon: "..."}]
    property int currentIndex: 0
    signal activated(int index)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 6
        color: theme.isDark ? "#202124" : "#E4E6EA"
        border.color: theme.borderColor
        border.width: 1

        // Smooth sliding active segment pill
        Rectangle {
            id: activePill
            visible: root.model && root.model.length > 0 && root.currentIndex >= 0 && root.currentIndex < root.model.length
            y: 2
            height: parent.height - 4
            width: root.model && root.model.length > 0 ? (parent.width - 4) / root.model.length : 0
            x: 2 + root.currentIndex * width
            radius: 5
            color: theme.isDark ? "#35383F" : "#FFFFFF"
            border.color: theme.isDark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
            border.width: 1

            Behavior on x {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 0

            Repeater {
                model: root.model
                delegate: Item {
                    id: segItem
                    required property int index
                    required property var modelData

                    readonly property bool active: root.currentIndex === index
                    readonly property string segLabel: typeof modelData === "string" ? modelData : (modelData.label || "")
                    readonly property string segIcon: (typeof modelData === "object" && modelData.icon) ? modelData.icon : ""

                    width: (bg.width - 4) / (root.model.length || 1)
                    height: parent.height
                    clip: true

                    Codicon {
                        id: segmentIcon
                        visible: segItem.segIcon !== ""
                        icon: segItem.segIcon
                        iconSize: 13
                        iconColor: segItem.active ? (theme.isDark ? "#FFFFFF" : theme.accent) : theme.secondaryText
                        anchors.left: parent.left
                        anchors.leftMargin: 7
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on iconColor { ColorAnimation { duration: 140 } }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: segItem.segIcon !== "" ? 21 : 4
                        anchors.rightMargin: 4
                        text: segItem.segLabel
                        font.family: theme.bodyFont
                        font.pixelSize: segItem.segLabel.length > 7 ? 9 : 10
                        font.weight: segItem.active ? Font.DemiBold : Font.Normal
                        color: segItem.active ? (theme.isDark ? "#FFFFFF" : theme.primaryText) : theme.secondaryText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideNone
                        wrapMode: Text.NoWrap
                        scale: segTap.pressed ? 0.94 : (segHov.hovered ? 1.02 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                        Behavior on color { ColorAnimation { duration: 140 } }
                    }

                    CustomToolTip {
                        visible: segHov.hovered
                        text: segItem.segLabel
                        delay: 500
                    }

                    HoverHandler {
                        id: segHov
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        id: segTap
                        gesturePolicy: TapHandler.ReleaseWithinBounds
                        onTapped: {
                            root.currentIndex = index
                            root.activated(index)
                        }
                    }
                }
            }
        }
    }
}

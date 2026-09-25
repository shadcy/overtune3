import QtQuick
import QtQuick.Controls

// StyledCombo.qml — bounded popup, eliding text, overflow-safe
ComboBox {
    id: root
    implicitHeight: 28
    implicitWidth: 120
    width: parent ? parent.width : implicitWidth
    font.family: "Inter"
    font.pixelSize: 13
    clip: true

    background: Rectangle {
        radius: 7
        color: root.pressed ? theme.surfaceHigh : theme.surface
        border.color: root.activeFocus ? theme.accent : theme.borderColor
        border.width: root.activeFocus ? 1.5 : 1
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        leftPadding: 10
        rightPadding: 22
        text: root.displayText
        font: root.font
        color: theme.primaryText
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        width: root.width
    }

    indicator: Codicon {
        icon: "chevron-right"
        iconSize: 12
        iconColor: theme.secondaryText
        rotation: 90
        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        width: 14
        height: 14
    }

    popup: Popup {
        y: root.height + 4
        width: Math.max(root.width, 120)
        padding: 4
        // Cap popup height so it never leaves the window
        implicitHeight: Math.min(list.contentHeight + padding * 2, 280)

        background: Rectangle {
            radius: 10
            color: theme.surface
            border.color: theme.borderColor
            border.width: 1
        }
        contentItem: ListView {
            id: list
            clip: true
            implicitHeight: contentHeight
            model: root.delegateModel
            currentIndex: root.highlightedIndex
            ScrollBar.vertical: ScrollBar {
                policy: list.contentHeight > list.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }
        }
    }

    delegate: ItemDelegate {
        width: ListView.view ? ListView.view.width : root.width
        height: 30
        contentItem: Text {
            text: modelData
            font.family: "Inter"
            font.pixelSize: 13
            color: highlighted ? theme.accent : theme.primaryText
            verticalAlignment: Text.AlignVCenter
            leftPadding: 8
            elide: Text.ElideRight
            width: parent.width
        }
        background: Rectangle {
            radius: 6
            color: highlighted ? theme.accentMuted : "transparent"
        }
        highlighted: root.highlightedIndex === index
    }
}

import QtQuick

// FilterCard.qml — Rounded content card
Rectangle {
    id: root
    color: theme.surface
    radius: 12
    border.color: theme.borderColor
    border.width: 1
    clip: true
    default property alias content: inner.data

    Item {
        id: inner
        anchors {
            fill: parent
            margins: 14
        }
        clip: true
    }

    Behavior on color { ColorAnimation { duration: 250 } }
}

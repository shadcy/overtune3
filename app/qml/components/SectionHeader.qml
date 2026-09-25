import QtQuick

// SectionHeader.qml — uppercase section label
Text {
    id: root
    font.family: "Stack Sans Headline"
    font.pixelSize: 11
    font.weight: Font.DemiBold
    font.letterSpacing: 0.8
    color: theme.secondaryText
    topPadding: 8
    bottomPadding: 4
    elide: Text.ElideRight
    width: parent ? parent.width : implicitWidth
}

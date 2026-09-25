import QtQuick
import QtQuick.Controls

// CodeViewer.qml — Monospaced code viewer with line numbers and responsive scrolling
Item {
    id: root
    property string code: ""

    // Calculate line count from code
    readonly property var lines: root.code.split("\n")
    readonly property int lineCount: lines.length

    Rectangle {
        anchors.fill: parent
        color: theme.isDark ? "#1E1E1E" : "#FFFFFF"
        radius: 6
        border.color: theme.borderColor
        border.width: 1
        clip: true

        ScrollView {
            id: codeScroll
            anchors.fill: parent
            anchors.margins: 2
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy:   ScrollBar.AsNeeded

            Row {
                spacing: 0
                height: Math.max(codeScroll.height, codeEdit.implicitHeight + 20)

                // Line numbers gutter
                Rectangle {
                    width: Math.max(38, (root.lineCount.toString().length * 8) + 18)
                    height: parent.height
                    color: theme.isDark ? "#1A1A1A" : "#F8F8F8"

                    Rectangle {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        width: 1
                        color: theme.borderColor
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        spacing: 0

                        Repeater {
                            model: root.lineCount
                            Text {
                                text: (index + 1).toString()
                                font.family: "Monospace"
                                font.pixelSize: 12
                                color: theme.secondaryText
                                height: 18
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }

                // Code text area
                TextEdit {
                    id: codeEdit
                    readOnly: true
                    text: root.code
                    font.family: "Monospace"
                    font.pixelSize: 12
                    color: theme.isDark ? "#D4D4D4" : "#24292E"
                    wrapMode: TextEdit.NoWrap
                    selectByMouse: true
                    padding: 10
                    topPadding: 10
                    selectionColor: theme.isDark ? "#264F78" : "#ADD6FF"
                }
            }
        }
    }
}

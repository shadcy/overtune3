import QtQuick
import QtQuick.Controls

// CodeViewer.qml — Monospaced code viewer with copy button and syntax highlighting bg
Item {
    id: root
    property string code: ""

    Rectangle {
        anchors.fill: parent
        color: theme.isDark ? "#1A1A2E" : "#F0F0F8"
        radius: 10
        border.color: theme.borderColor
        border.width: 1

        // Copy button
        StyledButton {
            id: copyBtn
            anchors {
                top: parent.top
                right: parent.right
                margins: 10
            }
            text: "Copy"
            primary: false
            implicitWidth: 70
            implicitHeight: 26
            font.pixelSize: 12
            onClicked: {
                exportModel.copyToClipboard()
                text = "Copied!"
                resetTimer.restart()
            }

            Timer {
                id: resetTimer
                interval: 1500
                onTriggered: copyBtn.text = "Copy"
            }
        }

        ScrollView {
            anchors {
                fill: parent
                margins: 12
                topMargin: 40
            }
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy:   ScrollBar.AsNeeded

            TextEdit {
                readOnly: true
                text: root.code
                font.family: "Noto Sans Mono, Liberation Mono, monospace"
                font.pixelSize: 12
                color: theme.primaryText
                wrapMode: TextEdit.NoWrap
                selectByMouse: true
                width: Math.max(root.width - 48, implicitWidth)
            }
        }
    }
}

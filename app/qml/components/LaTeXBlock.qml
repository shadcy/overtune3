import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// LaTeXBlock.qml — Clean LaTeX equation renderer with primary blue accents and clean typography
Item {
    id: root
    width: parent ? parent.width : 500
    implicitHeight: mainCol.implicitHeight + 24

    property string eqId: "" // e.g. "eq1", "eq2", etc.
    property string title: ""
    property string renderedHtml: ""
    property string latexSource: ""
    property string equationNumber: ""
    property bool showLatexSource: false
    property bool copiedNotice: false

    Timer {
        id: copyTimer
        interval: 1800
        onTriggered: root.copiedNotice = false
    }

    // Primary blue vertical indicator line on left
    Rectangle {
        id: accentBar
        width: 3
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: 1.5
        color: theme.accent
    }

    Column {
        id: mainCol
        anchors.left: accentBar.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 16
        spacing: 10

        // Header bar with Title, Copy button, LaTeX toggle, and Equation number badge
        Row {
            width: parent.width
            spacing: 8

            Text {
                text: root.title
                font.family: "Stack Sans Headline"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: theme.primaryText
                visible: root.title.length > 0
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                Layout.fillWidth: true
                width: 1
                height: 1
            }

            // Copy LaTeX button
            Rectangle {
                visible: root.latexSource.length > 0
                width: copyBtnText.implicitWidth + 14
                height: 22
                radius: 4
                color: "transparent"
                border.color: theme.accent
                border.width: 1

                Text {
                    id: copyBtnText
                    anchors.centerIn: parent
                    text: root.copiedNotice ? "Copied!" : "Copy LaTeX"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: root.copiedNotice ? theme.accent : theme.primaryText
                }

                HoverHandler { id: copyHov; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (typeof filterEngine !== "undefined" && typeof filterEngine.copyText === "function") {
                            filterEngine.copyText(root.latexSource)
                            root.copiedNotice = true
                            copyTimer.restart()
                        }
                    }
                }
            }

            // LaTeX / Rendered Math Toggle badge
            Rectangle {
                visible: root.latexSource.length > 0
                width: toggleText.implicitWidth + 14
                height: 22
                radius: 4
                color: "transparent"
                border.color: theme.accent
                border.width: 1

                Text {
                    id: toggleText
                    anchors.centerIn: parent
                    text: root.showLatexSource ? "Rendered Math" : "LaTeX"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: theme.accent
                }

                HoverHandler { id: togHov; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: root.showLatexSource = !root.showLatexSource
                }
            }

            // Equation Number Badge e.g. (1)
            Text {
                visible: root.equationNumber.length > 0
                text: root.equationNumber
                font.family: "Stack Sans Headline"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: theme.secondaryText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Rendered Equation Display
        Item {
            width: parent.width
            implicitHeight: Math.max(eqImg.height, eqHtml.implicitHeight, 40)

            // High-resolution pre-rendered math PNG
            Image {
                id: eqImg
                visible: !root.showLatexSource && status === Image.Ready
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                mipmap: true
                source: root.eqId.length > 0
                    ? ("qrc:/math/" + root.eqId + "_" + (theme.isDark ? "dark" : "light") + ".png")
                    : ""
            }

            // Fallback: Styled HTML math equation
            Text {
                id: eqHtml
                visible: !root.showLatexSource && eqImg.status !== Image.Ready
                width: parent.width
                text: root.renderedHtml
                textFormat: Text.RichText
                font.family: "Times New Roman, Cambria Math, serif"
                font.pixelSize: 15
                color: theme.primaryText
                wrapMode: Text.WordWrap
                lineHeight: 1.4
            }

            // Raw LaTeX source display
            Rectangle {
                visible: root.showLatexSource
                width: parent.width
                implicitHeight: latexCode.implicitHeight + 16
                radius: 4
                color: theme.isDark ? "#141416" : "#F0F0F2"
                border.color: theme.accent
                border.width: 1

                TextEdit {
                    id: latexCode
                    anchors.fill: parent
                    anchors.margins: 8
                    readOnly: true
                    selectByMouse: true
                    text: root.latexSource
                    font.family: "Monospace"
                    font.pixelSize: 12
                    color: theme.accent
                    wrapMode: TextEdit.WrapAnywhere
                }
            }
        }
    }
}

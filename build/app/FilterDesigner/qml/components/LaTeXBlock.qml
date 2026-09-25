import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// LaTeXBlock.qml — High-resolution compiled LaTeX equation renderer with raw LaTeX toggle & copy
Rectangle {
    id: root
    width: parent ? parent.width : 500
    implicitHeight: mainCol.implicitHeight + 20
    radius: 6
    color: theme.isDark ? "#1E1E1E" : "#F8F9FA"
    border.color: theme.borderColor
    border.width: 1
    clip: true

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

    Column {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 10

        // Header bar with Title, Copy button, LaTeX toggle, and Equation number badge
        Row {
            width: parent.width
            spacing: 8

            Text {
                text: root.title
                font.family: "Stack Sans Headline"
                font.pixelSize: 12
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
                color: root.copiedNotice
                    ? (theme.isDark ? "#1C3D27" : "#E6F4EA")
                    : (copyHov.hovered ? (theme.isDark ? "#2A2D2E" : "#E4E4E4") : "transparent")
                border.color: root.copiedNotice ? "#30D158" : theme.borderColor
                border.width: 1

                Text {
                    id: copyBtnText
                    anchors.centerIn: parent
                    text: root.copiedNotice ? "Copied!" : "Copy LaTeX"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: root.copiedNotice ? "#30D158" : theme.secondaryText
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
                color: togHov.hovered ? (theme.isDark ? "#2D3748" : "#E2E8F0") : (theme.isDark ? "#25282A" : "#EDEDED")
                border.color: theme.borderColor
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
            Rectangle {
                visible: root.equationNumber.length > 0
                width: eqNumText.implicitWidth + 10
                height: 22
                radius: 4
                color: theme.isDark ? "#25282A" : "#EDEDED"
                border.color: theme.borderColor
                border.width: 1

                Text {
                    id: eqNumText
                    anchors.centerIn: parent
                    text: root.equationNumber
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: theme.secondaryText
                }
            }
        }

        // Rendered Equation Container
        Rectangle {
            width: parent.width
            implicitHeight: root.eqId.length > 0 ? 94 : Math.max(50, renderedText.implicitHeight + 20)
            color: theme.isDark ? "#161616" : "#FFFFFF"
            radius: 4
            border.color: theme.borderColor
            border.width: 1
            visible: !root.showLatexSource
            clip: true

            // Compiled LaTeX Equation image (300 DPI, transparent, dark/light theme aware)
            Image {
                id: eqImg
                visible: root.eqId.length > 0
                anchors.centerIn: parent
                source: root.eqId.length > 0 ? ("qrc:/FilterDesigner/math/" + root.eqId + "_" + (theme.isDark ? "dark" : "light") + ".png") : ""
                fillMode: Image.PreserveAspectFit
                mipmap: true
                smooth: true
                width: Math.max(10, parent.width - 32)
                height: Math.max(10, parent.height - 18)
            }

            // Fallback Rich Text rendering
            Text {
                id: renderedText
                visible: root.eqId.length === 0
                anchors.centerIn: parent
                width: parent.width - 24
                text: root.renderedHtml
                textFormat: Text.RichText
                font.family: "Stack Sans Headline"
                font.pixelSize: 18
                color: theme.primaryText
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // Raw LaTeX Code Block
        Rectangle {
            width: parent.width
            implicitHeight: Math.max(38, rawCodeCol.implicitHeight + 14)
            radius: 4
            color: theme.isDark ? "#141414" : "#F4F4F4"
            border.color: theme.borderColor
            border.width: 1
            visible: root.showLatexSource

            Column {
                id: rawCodeCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: root.latexSource
                    font.family: "Monospace"
                    font.pixelSize: 12
                    color: theme.isDark ? "#9CDCFE" : "#001080"
                    wrapMode: Text.WrapAnywhere
                    width: parent.width
                }
            }
        }
    }
}

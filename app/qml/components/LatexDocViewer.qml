import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

// LatexDocViewer.qml — High-resolution compiled LaTeX PDF document viewer with zoom & external link notifications
Item {
    id: root
    width: parent ? parent.width : 800
    implicitHeight: mainCol.implicitHeight + 40

    property string docTitle: "Documentation"
    property string docSubtitle: ""
    property string docBaseName: "theory_and_math"
    property int    pageCount: 1
    property string pdfFileName: "theory_and_math.pdf"
    property var    externalLinks: []

    property real   pageZoom: 1.0

    function notifyAndOpen(url) {
        const w = Window.window
        if (w && typeof w.showNotification === "function") {
            w.showNotification("Opening external link: " + url, false)
        }
        Qt.openUrlExternally(url)
    }

    function openPdfFile() {
        const fullPath = "file:///home/shreyash/Desktop/Anti-gravity/overtune3/latex/" + root.pdfFileName
        const w = Window.window
        if (w && typeof w.showNotification === "function") {
            w.showNotification("Opening external PDF: " + root.pdfFileName, false)
        }
        Qt.openUrlExternally(fullPath)
    }

    Column {
        id: mainCol
        width: parent.width
        spacing: 18

        // ── Document Header & Action Toolbar ──────────────────────────────────
        Rectangle {
            width: parent.width
            height: toolBarRow.implicitHeight + 16
            radius: 8
            color: theme.isDark ? "#222326" : "#F3F4F6"
            border.color: theme.borderColor
            border.width: 1

            RowLayout {
                id: toolBarRow
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: 12
                }
                spacing: 12

                // Title & Page Count Badge
                Row {
                    Layout.fillWidth: true
                    spacing: 10
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: root.docTitle
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        visible: root.pageCount > 0
                        width: pageBadgeText.implicitWidth + 14
                        height: 22
                        radius: 11
                        color: theme.isDark ? "#2A2D34" : "#E4E6EA"
                        border.color: theme.borderColor
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: pageBadgeText
                            anchors.centerIn: parent
                            text: root.pageCount + (root.pageCount === 1 ? " Page" : " Pages")
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: theme.secondaryText
                        }
                    }
                }

                // Zoom controls
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignVCenter

                    Rectangle {
                        width: 28; height: 26
                        radius: 5
                        color: zoomOutHov.hovered ? (theme.isDark ? "#35383F" : "#E2E4E8") : (theme.isDark ? "#2A2C31" : "#EAECF0")
                        border.color: theme.borderColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "−"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.bold: true
                            color: theme.primaryText
                        }
                        HoverHandler { id: zoomOutHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.pageZoom = Math.max(0.75, root.pageZoom - 0.1) }
                    }

                    Rectangle {
                        width: 48; height: 26
                        radius: 5
                        color: theme.isDark ? "#1C1D20" : "#FFFFFF"
                        border.color: theme.borderColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: Math.round(root.pageZoom * 100) + "%"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: theme.primaryText
                        }
                        HoverHandler { id: zoomResetHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.pageZoom = 1.0 }
                    }

                    Rectangle {
                        width: 28; height: 26
                        radius: 5
                        color: zoomInHov.hovered ? (theme.isDark ? "#35383F" : "#E2E4E8") : (theme.isDark ? "#2A2C31" : "#EAECF0")
                        border.color: theme.borderColor
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.bold: true
                            color: theme.primaryText
                        }
                        HoverHandler { id: zoomInHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: root.pageZoom = Math.min(1.5, root.pageZoom + 0.1) }
                    }
                }

                // Open in System PDF Reader button
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    implicitWidth: openPdfContent.implicitWidth + 18
                    implicitHeight: 28
                    radius: 6
                    color: pdfBtnHov.hovered ? theme.accent : (theme.isDark ? "#2D3036" : "#E4E6EA")
                    border.color: pdfBtnHov.hovered ? theme.accent : theme.borderColor
                    border.width: 1

                    Row {
                        id: openPdfContent
                        anchors.centerIn: parent
                        spacing: 6

                        Codicon {
                            icon: "link-external"
                            iconSize: 12
                            iconColor: pdfBtnHov.hovered ? "#FFFFFF" : theme.primaryText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Open System PDF"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: pdfBtnHov.hovered ? "#FFFFFF" : theme.primaryText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    HoverHandler { id: pdfBtnHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: root.openPdfFile() }
                }
            }
        }

        // ── Rendered LaTeX PDF Pages Stack ────────────────────────────────────
        Column {
            id: pagesStack
            width: parent.width
            spacing: 24

            Repeater {
                model: root.pageCount
                delegate: Column {
                    width: pagesStack.width
                    spacing: 8

                    // Page tag badge
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6
                        Rectangle {
                            width: pageNumBadge.implicitWidth + 14
                            height: 20
                            radius: 10
                            color: theme.isDark ? "#2B2C30" : "#E5E7EB"
                            border.color: theme.borderColor
                            border.width: 1

                            Text {
                                id: pageNumBadge
                                anchors.centerIn: parent
                                text: "Page " + (index + 1) + " of " + root.pageCount
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: theme.secondaryText
                            }
                        }
                    }

                    // High-resolution LaTeX page paper container
                    Rectangle {
                        id: pagePaper
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(parent.width - 8, Math.round(820 * root.pageZoom))
                        height: Math.round(width * 1.414) // A4 aspect ratio 1 : sqrt(2)
                        radius: 4
                        color: "#FFFFFF"
                        border.color: theme.isDark ? "#3A3B40" : "#D1D5DB"
                        border.width: 1
                        clip: true

                        // Ambient page shadow effect
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -1
                            radius: 5
                            color: "transparent"
                            border.color: theme.isDark ? Qt.rgba(0, 0, 0, 0.5) : Qt.rgba(0, 0, 0, 0.08)
                            border.width: 1
                            z: -1
                        }

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: "qrc:/FilterDesigner/latex/" + root.docBaseName + "_page-" + (index + 1) + ".png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            asynchronous: false
                        }
                    }
                }
            }
        }

        // ── Canonical References & External Hyperlinks ────────────────────────
        Rectangle {
            width: parent.width
            implicitHeight: refCol.implicitHeight + 28
            radius: 8
            color: theme.surface
            border.color: theme.borderColor
            border.width: 1
            visible: root.externalLinks && root.externalLinks.length > 0

            Column {
                id: refCol
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: 18
                }
                topPadding: 14
                bottomPadding: 14
                spacing: 12

                Row {
                    spacing: 8
                    Codicon {
                        icon: "book"
                        iconSize: 15
                        iconColor: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "References & Canonical Literature (Underlined External Links)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Repeater {
                    model: root.externalLinks
                    delegate: Item {
                        required property var modelData
                        width: refCol.width
                        height: linkRow.implicitHeight + 4

                        RowLayout {
                            id: linkRow
                            width: parent.width
                            spacing: 8

                            Text {
                                text: "•"
                                font.pixelSize: 14
                                color: theme.accent
                                Layout.alignment: Qt.AlignTop
                            }

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                // Clickable underlined title
                                Text {
                                    text: modelData.title
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: true
                                    color: linkHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    elide: Text.ElideRight
                                    width: parent.width

                                    HoverHandler {
                                        id: linkHov
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                    TapHandler {
                                        onTapped: root.notifyAndOpen(modelData.url)
                                    }
                                }

                                Text {
                                    text: modelData.desc || modelData.url
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    title: "Overtune " + updateInstaller.currentVersion + " — What's New"
    width:         520
    height:        Math.min(620, Screen.desktopAvailableHeight ? Screen.desktopAvailableHeight - 80 : 600)
    minimumWidth:  460
    minimumHeight: 460
    maximumWidth:  600
    maximumHeight: 760

    color: theme.background
    palette.window: theme.background
    palette.windowText: theme.primaryText
    palette.base: theme.surface
    palette.text: theme.primaryText
    palette.button: theme.surfaceHigh
    palette.buttonText: theme.primaryText
    palette.highlight: theme.accent
    palette.highlightedText: "#FFFFFF"
    palette.mid: theme.borderColor
    visible: false
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint

    function openWindow() {
        if (!visible) {
            if (transientParent) {
                x = Math.max(0, transientParent.x + (transientParent.width - width) / 2)
                y = Math.max(0, transientParent.y + (transientParent.height - height) / 2)
            } else if (Screen.desktopAvailableWidth && Screen.desktopAvailableHeight) {
                x = Math.max(0, (Screen.desktopAvailableWidth - width) / 2)
                y = Math.max(0, (Screen.desktopAvailableHeight - height) / 2)
            }
            visible = true
            fadeIn.restart()
        }
        raise()
        requestActivate()
    }

    NumberAnimation {
        id: fadeIn
        target: scrollView
        property: "opacity"
        from: 0; to: 1
        duration: 240
        easing.type: Easing.OutCubic
    }

    Shortcut { sequence: "Escape"; onActivated: root.close() }

    // ── Full scroll: banner + content all scroll together ─────────────────────
    ScrollView {
        id: scrollView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: footer.top }
        clip: true
        contentWidth: availableWidth
        contentHeight: mainCol.implicitHeight
        opacity: 0
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical: ScrollBar {
            id: whatsNewScrollBar
            policy: ScrollBar.AsNeeded
            hoverEnabled: true
            width: 8
            contentItem: Rectangle {
                implicitWidth: 6
                radius: 3
                color: whatsNewScrollBar.pressed ? theme.accent
                     : (whatsNewScrollBar.hovered ? theme.secondaryText : theme.borderColor)
            }
            background: Item {}
        }

        Column {
            id: mainCol
            width: scrollView.availableWidth
            spacing: 0


            // ── 16:9 Banner ───────────────────────────────────────────────────
            Item {
                width: parent.width
                height: width * 9.0 / 16.0   // 292.5 px
                clip: true

                Image {
                    anchors.fill: parent
                    source: "qrc:/FilterDesigner/icons/banner.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }

                // Bottom gradient fade to match theme background
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 80
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: theme.background }
                    }
                }

                // Version pill — top right
                Rectangle {
                    anchors { top: parent.top; right: parent.right; margins: 14 }
                    height: 22
                    width: vLabel.implicitWidth + 22
                    radius: 11
                    color: "#000000"
                    opacity: 0.8
                    border.color: "#FFFFFF"
                    border.width: 1

                    Text {
                        id: vLabel
                        anchors.centerIn: parent
                        text: "v" + updateInstaller.currentVersion
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: "#FFFFFF"
                        font.letterSpacing: 0.8
                    }
                }
            }

            // ── Headline ──────────────────────────────────────────────────────
            Item { width: 1; height: 20 }

            Text {
                x: 36
                width: parent.width - 72
                text: "What's new in Overtune " + updateInstaller.currentVersion
                font.pixelSize: 28
                font.weight: Font.Bold
                color: theme.primaryText
                lineHeight: 1.22
                wrapMode: Text.Wrap
            }

            Item { width: 1; height: 10 }

            Text {
                x: 36
                width: parent.width - 72
                text: "Choose an install folder, set up shortcuts, and use the app's selected appearance."
                font.pixelSize: 13
                color: theme.secondaryText
                wrapMode: Text.Wrap
                lineHeight: 1.55
            }

            Item { width: 1; height: 32 }

            // ── NEW Section ───────────────────────────────────────────────────
            Rectangle {
                x: 36
                width: newLabel.implicitWidth + 14
                height: newLabel.implicitHeight + 8
                radius: 4
                color: theme.accent

                Text {
                    id: newLabel
                    anchors.centerIn: parent
                    text: "NEW"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    font.letterSpacing: 1.5
                }
            }

            Item { width: 1; height: 18 }

            Repeater {
                model: [
                    { n: "1", title: "Choose an install folder",
                      desc: "Select a destination in setup or type a path." },
                    { n: "2", title: "Readable plot labels",
                      desc: "Axis labels use solid black backgrounds and sit clear of tick values." },
                    { n: "3", title: "Clear version details",
                      desc: "See the installed and available versions in the update view." }
                ]

                delegate: Row {
                    x: 36
                    width: parent.width - 72
                    bottomPadding: 20
                    spacing: 12

                    Text {
                        width: 18
                        text: modelData.n + "."
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: theme.accent
                        topPadding: 1
                    }

                    Column {
                        width: parent.width - 30
                        spacing: 4

                        Text {
                            width: parent.width
                            text: modelData.title
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: theme.primaryText
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: modelData.desc
                            font.pixelSize: 12
                            color: theme.secondaryText
                            wrapMode: Text.Wrap
                            lineHeight: 1.55
                        }
                    }
                }
            }

            Item { width: 1; height: 8 }

            // Divider
            Rectangle {
                x: 36; width: parent.width - 72; height: 1
                color: theme.borderColor
            }

            Item { width: 1; height: 28 }

            // ── IMPROVED Section ──────────────────────────────────────────────
            Rectangle {
                x: 36
                width: improvedLabel.implicitWidth + 14
                height: improvedLabel.implicitHeight + 8
                radius: 4
                color: theme.accent

                Text {
                    id: improvedLabel
                    anchors.centerIn: parent
                    text: "IMPROVED"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    font.letterSpacing: 1.5
                }
            }

            Item { width: 1; height: 18 }

            Repeater {
                model: [
                    { n: "4", title: "Clean version transitions & update flows",
                      desc: "Accurate version indicators and installer layouts without text clipping." },
                    { n: "5", title: "Theme-aware setup windows",
                      desc: "Installer and update windows follow the app's dark or light appearance." }
                ]

                delegate: Row {
                    x: 36
                    width: parent.width - 72
                    bottomPadding: 20
                    spacing: 12

                    Text {
                        width: 18
                        text: modelData.n + "."
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: theme.accent
                        topPadding: 1
                    }

                    Column {
                        width: parent.width - 30
                        spacing: 4

                        Text {
                            width: parent.width
                            text: modelData.title
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: theme.primaryText
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: modelData.desc
                            font.pixelSize: 12
                            color: theme.secondaryText
                            wrapMode: Text.Wrap
                            lineHeight: 1.55
                        }
                    }
                }
            }

            Item { width: 1; height: 32 }
        }
    }

    // ── Fixed footer ──────────────────────────────────────────────────────────
    Rectangle {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 60
        color: theme.surface
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: theme.borderColor
        }

        Text {
            anchors { left: parent.left; leftMargin: 36; verticalCenter: parent.verticalCenter }
            text: "Release " + updateInstaller.currentVersion + " (2026)"
            font.pixelSize: 11
            color: theme.secondaryText
            font.letterSpacing: 0.2
        }

        // Dynamic accent "Got it" button
        Rectangle {
            anchors { right: parent.right; rightMargin: 36; verticalCenter: parent.verticalCenter }
            implicitWidth:  80
            implicitHeight: 30
            radius: 7
            color: closeMouse.pressed ? Qt.darker(theme.accent, 1.2) : theme.accent
            Behavior on color { ColorAnimation { duration: 100 } }

            Text {
                anchors.centerIn: parent
                text: "Got it"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: "#FFFFFF"
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.close()
            }
        }
    }
}

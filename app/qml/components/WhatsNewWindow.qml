import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    title: "Overtune 3.2.3 — What's New"
    width:         520
    height:        Math.min(620, Screen.desktopAvailableHeight ? Screen.desktopAvailableHeight - 80 : 600)
    minimumWidth:  460
    minimumHeight: 460
    maximumWidth:  600
    maximumHeight: 760

    color: theme.isDark ? (theme.oledMode ? "#000000" : "#111113") : "#F5F5F7"
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
        ScrollBar.vertical.policy:   ScrollBar.AsNeeded

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
                    source: "qrc:/FilterDesigner/icons/16-9ar-logo.png"
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
                        GradientStop { position: 1.0; color: theme.isDark ? (theme.oledMode ? "#000000" : "#111113") : "#F5F5F7" }
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
                        text: "v3.2.3"
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
                text: "What's new in Overtune 3.2.3"
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
                text: "Native installation directory selection, solid-contrast plot math badges, authentic Codicons, and refined UI styling."
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
                    { n: "1", title: "Target directory selection in installer",
                      desc: "Choose any custom installation destination directly in the setup wizard via native folder picker." },
                    { n: "2", title: "Solid black math badges in all plots",
                      desc: "Mathematical symbols are rendered against solid black squircle badges with clear separation from axis numbers." },
                    { n: "3", title: "Full authentic Codicon icon set",
                      desc: "Zero missing glyphs or question mark icons across all views and settings dialogs." }
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
                      desc: "Accurate v3.2.2 → v3.2.3 version indicators and dynamic button layouts without text clipping." },
                    { n: "5", title: "Clean Apple-inspired aesthetics",
                      desc: "Disciplined typography, zero marketing filler, and harmonious dark/light mode surface hierarchy." }
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
        color: theme.isDark ? "#0C0C0E" : "#EBEBED"
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: theme.borderColor
        }

        Text {
            anchors { left: parent.left; leftMargin: 36; verticalCenter: parent.verticalCenter }
            text: "Release 3.2.3 (2026)"
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
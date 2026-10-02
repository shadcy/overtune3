import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    title: "Overtune 3.2.1 — What's New"
    width:         520
    height:        Math.min(620, Screen.desktopAvailableHeight ? Screen.desktopAvailableHeight - 80 : 600)
    minimumWidth:  460
    minimumHeight: 460
    maximumWidth:  600
    maximumHeight: 760

    color: "#000000"
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

                // Bottom gradient fade to black
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 80
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: "#000000" }
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
                        text: "v3.2.1"
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
                text: "What's new in Overtune 3.2.1"
                font.pixelSize: 30
                font.weight: Font.Bold
                color: "#FFFFFF"
                lineHeight: 1.22
                wrapMode: Text.Wrap
            }

            Item { width: 1; height: 10 }

            Text {
                x: 36
                width: parent.width - 72
                text: "Major DSP precision upgrades, new plot windows, and a refined studio workflow — all in one release."
                font.pixelSize: 13
                color: "#FFFFFF"
                opacity: 0.45
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
                color: theme.accent // Dynamic accent color from settings

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
                    { n: "1", title: "Standalone plot windows",
                      desc: "Pop any plot into its own native window. Supports high-resolution PNG export, clipboard copy, and live auto-scaling across all plot types." },
                    { n: "2", title: "Pole-zero multiplicity & Q readouts",
                      desc: "MATLAB zplane-style multiplicity badges for coincident poles/zeros. Resonant Q-factor and natural frequency displayed on hover." },
                    { n: "3", title: "Step response asymptotes & metrics",
                      desc: "Theoretical DC gain reference line with stepinfo-style overshoot percentage and settling time annotations on the impulse/step plot." }
                ]

                delegate: Row {
                    x: 36
                    width: parent.width - 72
                    bottomPadding: 20
                    spacing: 12

                    // Fixed width number for perfect alignment
                    Text {
                        width: 18
                        text: modelData.n + "."
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        topPadding: 1
                    }

                    Column {
                        width: parent.width - 30 // parent width - spacing(12) - number width(18)
                        spacing: 4

                        Text {
                            width: parent.width
                            text: modelData.title
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: modelData.desc
                            font.pixelSize: 12
                            color: "#FFFFFF"
                            opacity: 0.55 // Adjusted for slightly better contrast
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
                color: "#FFFFFF"; opacity: 0.08
            }

            Item { width: 1; height: 28 }

            // ── IMPROVED Section ──────────────────────────────────────────────
            Rectangle {
                x: 36
                width: improvedLabel.implicitWidth + 14
                height: improvedLabel.implicitHeight + 8
                radius: 4
                color: theme.accent // Dynamic accent color from settings

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
                    { n: "4", title: "MATLAB-grade DSP precision",
                      desc: "Exact cutoff frequency anchoring into the analysis grid. Adaptive transition clustering down to 0.001 Hz. Zero discretization error at all band edges." },
                    { n: "5", title: "Singularity-free group delay",
                      desc: "Poisson-regularized group delay eliminates infinite spikes at unit-circle zeros. Smooth continuous phase unwrapping across Butterworth, Chebyshev, Elliptic, and Bessel designs." }
                ]

                delegate: Row {
                    x: 36
                    width: parent.width - 72
                    bottomPadding: 20
                    spacing: 12

                    // Fixed width number for perfect alignment
                    Text {
                        width: 18
                        text: modelData.n + "."
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
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
                            color: "#FFFFFF"
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: modelData.desc
                            font.pixelSize: 12
                            color: "#FFFFFF"
                            opacity: 0.55
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
        color: "#0c0c0e"
        z: 10

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: "#FFFFFF"
            opacity: 0.08
        }

        Text {
            anchors { left: parent.left; leftMargin: 36; verticalCenter: parent.verticalCenter }
            text: "Release 3.2.1 (2026)"
            font.pixelSize: 11
            color: "#FFFFFF"
            opacity: 0.25
            font.letterSpacing: 0.2
        }

        // Dynamic accent "Got it" button
        Rectangle {
            anchors { right: parent.right; rightMargin: 36; verticalCenter: parent.verticalCenter }
            implicitWidth:  80
            implicitHeight: 30
            radius: 7
            color: closeMouse.pressed ? "#0071E3" : (closeMouse.containsMouse ? theme.accent : theme.accent)
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
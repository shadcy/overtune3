import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

// DesignVerifierModal.qml — Standalone 2-stage design verification window with OLED theme & 16:9 compliance banner
Window {
    id: root

    title: "Overtune 3 (beta) — Design Verifier"
    width:        520
    height:       540
    minimumWidth:  520
    minimumHeight: 540
    maximumWidth:  520
    maximumHeight: 540

    color: "#000000"
    visible: false
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint

    property bool isVerifying: false
    property var verResult: null
    property real progress: 0.0

    function openVerification() {
        if (!visible) {
            visible = true
        }
        raise()
        requestActivate()

        progressAnim.stop()
        progress = 0.0
        verResult = null
        isVerifying = true
        progressAnim.start()
    }

    function closeVerification() {
        progressAnim.stop()
        close()
    }

    Shortcut { sequence: "Escape"; onActivated: root.closeVerification() }

    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        from: 0.0
        to: 1.0
        duration: 850
        easing.type: Easing.InOutQuad
        onFinished: {
            root.verResult = filterEngine.verifyDesign()
            root.isVerifying = false
        }
    }

    // Scrollable content area + sticky footer matching WhatsNewWindow layout
    ScrollView {
        id: scrollView
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: footer.top }
        clip: true
        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy:   ScrollBar.AsNeeded

        Column {
            width: parent.width
            spacing: 0

            // ── 16:9 Compliance Banner ─────────────────────────────────────────
            Item {
                width: parent.width
                height: root.width * 9.0 / 16.0   // 292.5 px
                clip: true

                Image {
                    anchors.fill: parent
                    source: "qrc:/FilterDesigner/icons/16-9ar-compliance.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                }

                // Bottom gradient fade to OLED black
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

                // Compliance Pill — Top Right
                Rectangle {
                    anchors { top: parent.top; right: parent.right; margins: 14 }
                    height: 22
                    width: cLabel.implicitWidth + 22
                    radius: 11
                    color: "#000000"
                    opacity: 0.8
                    border.color: "#FFFFFF"
                    border.width: 1

                    Text {
                        id: cLabel
                        anchors.centerIn: parent
                        text: "COMPLIANCE"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        font.letterSpacing: 1.2
                    }
                }
            }

            // ── Content Padding Container ─────────────────────────────────────
            Column {
                width: parent.width - 48
                x: 24
                spacing: 16

                Item { width: 1; height: 4 }

                // Header Titles
                Column {
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "Stage 2 Verifier :)"
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        lineHeight: 1.2
                    }

                    Text {
                        text: "Automated 2-stage mathematical audit for stability & precision."
                        font.pixelSize: 13
                        color: "#FFFFFF"
                        opacity: 0.6
                        wrapMode: Text.Wrap
                        width: parent.width
                    }
                }

                Item { width: 1; height: 4 }

                // Accent Progress Bar Card
                Rectangle {
                    width: parent.width
                    height: 76
                    radius: 12
                    color: "#1C1C1E"
                    border.color: Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        // Top row: status label + percentage
                        RowLayout {
                            width: parent.width

                            Row {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 8

                                Codicon {
                                    id: spinIcon
                                    icon: root.isVerifying ? "refresh" : (root.verResult && !root.verResult.passed ? "error" : "check")
                                    iconSize: 14
                                    iconColor: !root.isVerifying && root.verResult && !root.verResult.passed ? "#FF3B30" : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter

                                    RotationAnimator {
                                        target: spinIcon
                                        running: root.isVerifying
                                        from: 0; to: 360; duration: 800; loops: Animation.Infinite
                                    }
                                }

                                Text {
                                    text: root.isVerifying ? "Verifying Design..." : (root.verResult && !root.verResult.passed ? "Verification Flagged Anomalies" : "Verification Complete")
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    color: "#FFFFFF"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: Math.round(root.progress * 100) + "%"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: !root.isVerifying && root.verResult && !root.verResult.passed ? "#FF3B30" : theme.accent
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // Accent Progress Bar Track
                        Rectangle {
                            id: progressTrack
                            width: parent.width
                            height: 6
                            radius: 3
                            color: "#2C2C2E"
                            clip: true

                            Rectangle {
                                id: progressFill
                                height: parent.height
                                width: Math.max(0, Math.min(progressTrack.width, progressTrack.width * root.progress))
                                radius: 3
                                color: root.progress >= 1.0 && root.verResult && !root.verResult.passed ? "#FF3B30" : theme.accent
                            }
                        }
                    }
                }

                // Status Error Banner (only shown if verification fails/flags anomalies)
                Rectangle {
                    visible: !root.isVerifying && root.verResult !== null && !root.verResult.passed
                    width: parent.width
                    height: 44
                    radius: 10
                    color: Qt.rgba(1.0, 0.23, 0.19, 0.16)
                    border.color: Qt.rgba(1.0, 0.23, 0.19, 0.4)
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Codicon {
                            icon: "error"
                            iconSize: 14
                            iconColor: "#FF3B30"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (root.verResult && root.verResult.referenceModelVerified === false)
                                    ? ("Reference Model Discrepancy (Max error: " + Number(root.verResult.maxPointMagnitudeErrorDb).toFixed(3) + " dB)")
                                    : "Verification Flagged Mathematical Anomalies"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#FF3B30"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Item { width: 1; height: 20 }
            }
        }
    }

    // ── Sticky Footer (OLED Black) matching WhatsNewWindow ─────────────────────
    Item {
        id: footer
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 60

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 1
            color: "#FFFFFF"
            opacity: 0.1
        }

        Text {
            anchors { left: parent.left; leftMargin: 24; verticalCenter: parent.verticalCenter }
            text: "Overtune 3 Engine Audit"
            font.pixelSize: 11
            color: "#FFFFFF"
            opacity: 0.4
            font.letterSpacing: 0.4
        }

        // Dynamic accent "Got it" squircle button
        Rectangle {
            id: gotItBtn
            anchors { right: parent.right; rightMargin: 24; verticalCenter: parent.verticalCenter }
            implicitWidth:  80
            implicitHeight: 30
            radius: 7
            property bool isVerified: !root.isVerifying && root.verResult !== null && root.verResult.passed
            opacity: isVerified ? 1.0 : 0.4
            color: !isVerified ? "#2C2C2E" : (closeMouse.pressed ? Qt.darker(theme.accent, 1.25) : (closeMouse.containsMouse ? Qt.lighter(theme.accent, 1.1) : theme.accent))
            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

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
                enabled: gotItBtn.isVerified
                hoverEnabled: true
                cursorShape: gotItBtn.isVerified ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.closeVerification()
            }
        }
    }
}

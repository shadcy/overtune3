import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ChallengeStudio.qml — Interactive DSP Lab Challenge bar & automated real-time grading engine.
// Evaluates passband ripple, stopband attenuation, BIBO stability, and complexity constraints.
Rectangle {
    id: root
    width: parent.width
    implicitHeight: mainCol.implicitHeight + 24
    color: theme.isDark ? "#1C1D21" : "#F4F6F8"
    border.color: theme.borderColor
    border.width: 1
    clip: true
    visible: tutEngine && tutEngine.currentMode === 2
    z: 85

    property var tutEngine: null

    Column {
        id: mainCol
        anchors { left: parent.left; right: parent.right; margins: 20 }
        topPadding: 12
        bottomPadding: 12
        spacing: 12

        // ── Top Bar: Mode Title, Challenge Picker, and Exit Button ────────────
        RowLayout {
            width: parent.width

            Row {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: "#FF9F0A"
                    Codicon {
                        icon: "beaker"
                        iconSize: 13
                        iconColor: "#FFFFFF"
                        anchors.centerIn: parent
                    }
                }

                Text {
                    text: "DSP LAB CHALLENGE"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: "#FF9F0A"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Challenge Selector Tabs
            Row {
                spacing: 6
                Layout.alignment: Qt.AlignHCenter

                Repeater {
                    model: tutEngine ? tutEngine.challenges : []
                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        readonly property bool active: tutEngine.currentChallengeIndex === index
                        width: chTabTxt.implicitWidth + 20
                        height: 26
                        radius: 4
                        color: active
                            ? theme.accent
                            : (chHov.hovered ? (theme.isDark ? "#2C2E33" : "#E5E5E5") : (theme.isDark ? "#23252A" : "#ECECEC"))

                        Text {
                            id: chTabTxt
                            anchors.centerIn: parent
                            text: "0" + (index + 1) + " " + modelData.category
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: parent.active ? Font.DemiBold : Font.Normal
                            color: parent.active ? "#FFFFFF" : theme.primaryText
                        }

                        HoverHandler { id: chHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: tutEngine.selectChallenge(index) }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Score Badge
            Rectangle {
                height: 26
                width: scoreRow.implicitWidth + 18
                radius: 13
                color: (tutEngine && tutEngine.labEvaluation.allPassed) ? "#30D158" : (theme.isDark ? "#282B30" : "#E5E5E5")

                Row {
                    id: scoreRow
                    anchors.centerIn: parent
                    spacing: 6

                    Codicon {
                        icon: (tutEngine && tutEngine.labEvaluation.allPassed) ? "check" : "dashboard"
                        iconSize: 12
                        iconColor: (tutEngine && tutEngine.labEvaluation.allPassed) ? "#FFFFFF" : theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Score: " + (tutEngine ? tutEngine.labEvaluation.score : 0) + " / 4"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: (tutEngine && tutEngine.labEvaluation.allPassed) ? "#FFFFFF" : theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Close Lab Mode Button
            Rectangle {
                width: 24
                height: 24
                radius: 4
                color: exHov.hovered ? (theme.isDark ? "#3A3D41" : "#E5E5E5") : "transparent"
                Codicon {
                    icon: "close"
                    iconSize: 12
                    iconColor: theme.secondaryText
                    anchors.centerIn: parent
                }
                HoverHandler { id: exHov; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: tutEngine.setMode(0) }
            }
        }

        // ── Challenge Title & Goal Description ───────────────────────────────
        RowLayout {
            width: parent.width

            Column {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: tutEngine && tutEngine.activeChallenge ? tutEngine.activeChallenge.title : ""
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    color: theme.primaryText
                }

                Text {
                    text: tutEngine && tutEngine.activeChallenge ? tutEngine.activeChallenge.description : ""
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 12
                    color: theme.secondaryText
                }
            }
        }

        // ── Real-Time 4-Criterion DSP Scorecard ──────────────────────────────
        RowLayout {
            width: parent.width
            spacing: 12

            // Criterion 1: Passband Ripple
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 6
                color: (tutEngine && tutEngine.labEvaluation.passbandSatisfied)
                    ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#222428" : "#FFFFFF")
                border.color: (tutEngine && tutEngine.labEvaluation.passbandSatisfied)
                    ? "#30D158" : (theme.isDark ? "#33363B" : "#DDE0E5")
                border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 8

                    Codicon {
                        icon: (tutEngine && tutEngine.labEvaluation.passbandSatisfied) ? "check" : "circle-slash"
                        iconSize: 14
                        iconColor: (tutEngine && tutEngine.labEvaluation.passbandSatisfied) ? "#30D158" : theme.secondaryText
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Passband Ripple"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }
                        Text {
                            text: "≤ " + (tutEngine.activeChallenge ? tutEngine.activeChallenge.maxPassbandRipple : 1) + " dB (curr: " +
                                  (tutEngine ? tutEngine.labEvaluation.rippleInPass.toFixed(2) : "0") + " dB)"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 10
                            color: theme.secondaryText
                        }
                    }
                }
            }

            // Criterion 2: Stopband Attenuation
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 6
                color: (tutEngine && tutEngine.labEvaluation.stopbandSatisfied)
                    ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#222428" : "#FFFFFF")
                border.color: (tutEngine && tutEngine.labEvaluation.stopbandSatisfied)
                    ? "#30D158" : (theme.isDark ? "#33363B" : "#DDE0E5")
                border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 8

                    Codicon {
                        icon: (tutEngine && tutEngine.labEvaluation.stopbandSatisfied) ? "check" : "circle-slash"
                        iconSize: 14
                        iconColor: (tutEngine && tutEngine.labEvaluation.stopbandSatisfied) ? "#30D158" : theme.secondaryText
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Stopband Attenuation"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }
                        Text {
                            text: "≥ " + (tutEngine.activeChallenge ? tutEngine.activeChallenge.minStopbandAtten : 40) + " dB (curr: " +
                                  (tutEngine ? tutEngine.labEvaluation.attenuationAtStop.toFixed(1) : "0") + " dB)"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 10
                            color: theme.secondaryText
                        }
                    }
                }
            }

            // Criterion 3: BIBO Stability
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 6
                color: (tutEngine && tutEngine.labEvaluation.stabilitySatisfied)
                    ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#3A1B1C" : "#FCE8E6")
                border.color: (tutEngine && tutEngine.labEvaluation.stabilitySatisfied)
                    ? "#30D158" : "#FF453A"
                border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 8

                    Codicon {
                        icon: (tutEngine && tutEngine.labEvaluation.stabilitySatisfied) ? "check" : "error"
                        iconSize: 14
                        iconColor: (tutEngine && tutEngine.labEvaluation.stabilitySatisfied) ? "#30D158" : "#FF453A"
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "BIBO Stability"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }
                        Text {
                            text: "All |p| < 1.0 (max: " + (tutEngine ? tutEngine.labEvaluation.maxPoleRadius.toFixed(2) : "0") + ")"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 10
                            color: theme.secondaryText
                        }
                    }
                }
            }

            // Criterion 4: Complexity Constraint (Max Order)
            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 6
                color: (tutEngine && tutEngine.labEvaluation.orderSatisfied)
                    ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#222428" : "#FFFFFF")
                border.color: (tutEngine && tutEngine.labEvaluation.orderSatisfied)
                    ? "#30D158" : (theme.isDark ? "#33363B" : "#DDE0E5")
                border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 10 }
                    spacing: 8

                    Codicon {
                        icon: (tutEngine && tutEngine.labEvaluation.orderSatisfied) ? "check" : "circle-slash"
                        iconSize: 14
                        iconColor: (tutEngine && tutEngine.labEvaluation.orderSatisfied) ? "#30D158" : theme.secondaryText
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "Order Constraint"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }
                        Text {
                            text: "Order ≤ " + (tutEngine.activeChallenge ? tutEngine.activeChallenge.maxOrder : 8) + " (curr: " +
                                  (tutEngine ? tutEngine.labEvaluation.currentOrder : "4") + ")"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 10
                            color: theme.secondaryText
                        }
                    }
                }
            }
        }

        // ── Success Banner when all 4 criteria are satisfied ──────────────────
        Rectangle {
            visible: tutEngine && tutEngine.labEvaluation.allPassed
            width: parent.width
            height: 34
            radius: 5
            color: theme.isDark ? "#163E24" : "#D4EDDA"
            border.color: "#30D158"
            border.width: 1

            RowLayout {
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }

                Row {
                    spacing: 8
                    Codicon {
                        icon: "verified"
                        iconSize: 15
                        iconColor: "#30D158"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "All 4 Lab Criteria Satisfied! 🔓 Unlocked Badge: " + (tutEngine.activeChallenge ? tutEngine.activeChallenge.badge : "DSP Master") + " (+150 XP)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: theme.isDark ? "#4CD964" : "#155724"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: nextChTxt.implicitWidth + 16
                    height: 24
                    radius: 4
                    color: "#30D158"

                    Text {
                        id: nextChTxt
                        anchors.centerIn: parent
                        text: "Next Challenge →"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    HoverHandler { id: nchHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            tutEngine.selectChallenge((tutEngine.currentChallengeIndex + 1) % tutEngine.challenges.length)
                        }
                    }
                }
            }
        }
    }
}

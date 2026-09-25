import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// SpotlightOverlay.qml — Interactive Learning Walkthrough Overlay with
// pedagogical step guidance, prediction quizzes, live DSP goal tracking, and pole region illustrations.
Item {
    id: root
    anchors.fill: parent
    visible: tutEngine.currentMode === 1 && tutEngine.activeTutorial !== null
    z: 90

    property var tutEngine: null

    // Semi-transparent backdrop click catcher (does not block interaction with controls if minimized)
    MouseArea {
        anchors.fill: parent
        enabled: false // Allow clicks to pass through to underlying UI controls
    }

    // ── Floating Interactive Tutorial Guide Card ─────────────────────────────
    Rectangle {
        id: card
        width: Math.min(parent.width - 48, 560)
        implicitHeight: cardCol.implicitHeight + 32
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 20
        }
        radius: 10
        color: theme.isDark ? "#1F2023" : "#FFFFFF"
        border.color: theme.accent
        border.width: 1.5
        clip: true

        // Top accent line
        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 3
            color: theme.accent
        }

        Column {
            id: cardCol
            anchors { left: parent.left; right: parent.right; margins: 20 }
            topPadding: 16
            bottomPadding: 16
            spacing: 14

            // Header Bar: Category, Progress Dots, Close Button
            RowLayout {
                width: parent.width

                Row {
                    spacing: 8
                    Layout.fillWidth: true

                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                        Codicon {
                            icon: "mortar-board"
                            iconSize: 12
                            iconColor: "#FFFFFF"
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: (tutEngine.activeTutorial ? tutEngine.activeTutorial.title : "Interactive Tutorial")
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                    }
                }

                // Step Dots
                Row {
                    spacing: 6
                    Layout.alignment: Qt.AlignRight

                    Repeater {
                        model: (tutEngine.activeTutorial && tutEngine.activeTutorial.steps) ? tutEngine.activeTutorial.steps.length : 0
                        delegate: Rectangle {
                            required property int index
                            width: (tutEngine.currentStepIndex === index) ? 14 : 7
                            height: 7
                            radius: 3.5
                            color: (tutEngine.currentStepIndex === index)
                                ? theme.accent
                                : ((tutEngine.currentStepIndex > index) ? "#30D158" : (theme.isDark ? "#3A3D41" : "#D0D0D0"))
                            Behavior on width { NumberAnimation { duration: 150 } }
                        }
                    }
                }

                // Close Button
                Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: closeHov.hovered ? (theme.isDark ? "#3A3D41" : "#E5E5E5") : "transparent"
                    Codicon {
                        icon: "close"
                        iconSize: 12
                        iconColor: theme.secondaryText
                        anchors.centerIn: parent
                    }
                    HoverHandler { id: closeHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tutEngine.setMode(0) }
                }
            }

            // Step Title (H2)
            Text {
                width: parent.width
                text: tutEngine.currentStep ? tutEngine.currentStep.title : ""
                font.family: "Stack Sans Headline"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: theme.primaryText
                wrapMode: Text.WordWrap
            }

            // Step Instruction Body
            Text {
                width: parent.width
                textFormat: Text.RichText
                text: tutEngine.currentStep ? tutEngine.currentStep.instruction : ""
                font.family: "Stack Sans Headline"
                font.pixelSize: 13
                lineHeight: 1.5
                color: theme.isDark ? "#CCCCCC" : "#444444"
                wrapMode: Text.WordWrap
            }

            // ── Visual Highlight Diagram: Pole Region (when specified) ──────────
            Rectangle {
                visible: tutEngine.currentStep && tutEngine.currentStep.highlightRegion !== undefined
                width: parent.width
                height: 120
                radius: 6
                color: theme.isDark ? "#161719" : "#F6F8FA"
                border.color: theme.isDark ? "#2D3035" : "#E1E4E8"
                border.width: 1

                Canvas {
                    id: poleRegionCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var cx = width / 2
                        var cy = height / 2
                        var rOuter = Math.min(width, height) * 0.42
                        var rTarget = rOuter * 0.6

                        // Axes
                        ctx.strokeStyle = "#3A3D41"
                        ctx.lineWidth = 1
                        ctx.beginPath()
                        ctx.moveTo(cx - rOuter - 15, cy); ctx.lineTo(cx + rOuter + 15, cy)
                        ctx.moveTo(cx, cy - rOuter - 10); ctx.lineTo(cx, cy + rOuter + 10)
                        ctx.stroke()

                        // Unit circle |z| = 1
                        ctx.strokeStyle = "#4D535E"
                        ctx.beginPath()
                        ctx.arc(cx, cy, rOuter, 0, 2 * Math.PI)
                        ctx.stroke()

                        // Target region dashed circle (r ≈ 0.6)
                        ctx.strokeStyle = "#0A84FF"
                        ctx.lineWidth = 1.5
                        ctx.setLineDash([4, 4])
                        ctx.beginPath()
                        ctx.arc(cx, cy, rTarget, 0, 2 * Math.PI)
                        ctx.stroke()
                        ctx.setLineDash([])

                        // Draw conjugate pole markers along r ≈ 0.6
                        ctx.fillStyle = "#FF453A"
                        var angles = [Math.PI / 4, 3 * Math.PI / 4, -Math.PI / 4, -3 * Math.PI / 4]
                        for (var i = 0; i < angles.length; i++) {
                            var px = cx + rTarget * Math.cos(angles[i])
                            var py = cy - rTarget * Math.sin(angles[i])
                            ctx.beginPath()
                            ctx.arc(px, py, 4, 0, 2 * Math.PI)
                            ctx.fill()
                        }
                    }
                }

                Row {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 6 }
                    spacing: 8
                    Rectangle { width: 8; height: 8; radius: 4; color: "#FF453A"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Conjugate Poles (r ≈ 0.6)"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                    Rectangle { width: 8; height: 8; radius: 4; color: "#0A84FF"; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Resonance Band"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: "#0A84FF" }
                }
            }

            // ── Prediction Quiz Options (when currentStep.type === "predict") ───
            Column {
                visible: tutEngine.currentStep && tutEngine.currentStep.type === "predict"
                width: parent.width
                spacing: 8

                Repeater {
                    model: (tutEngine.currentStep && tutEngine.currentStep.options) ? tutEngine.currentStep.options : []
                    delegate: Rectangle {
                        required property int index
                        required property string modelData
                        width: parent.width
                        height: optRow.implicitHeight + 16
                        radius: 6
                        color: {
                            if (tutEngine.userPredictionChoice === index) {
                                return tutEngine.predictionCorrect ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#3A1B1C" : "#FCE8E6")
                            }
                            return optHov.hovered ? (theme.isDark ? "#282B30" : "#EFEFEF") : (theme.isDark ? "#222428" : "#F6F6F6")
                        }
                        border.color: (tutEngine.userPredictionChoice === index)
                            ? (tutEngine.predictionCorrect ? "#30D158" : "#FF453A")
                            : (optHov.hovered ? theme.accent : (theme.isDark ? "#33363B" : "#E0E0E0"))
                        border.width: 1

                        RowLayout {
                            id: optRow
                            anchors { left: parent.left; right: parent.right; margins: 12; verticalCenter: parent.verticalCenter }
                            spacing: 10

                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: (tutEngine.userPredictionChoice === index) ? (tutEngine.predictionCorrect ? "#30D158" : "#FF453A") : "transparent"
                                border.color: (tutEngine.userPredictionChoice === index) ? "transparent" : theme.secondaryText
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: String.fromCharCode(65 + index)
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: (tutEngine.userPredictionChoice === index) ? "#FFFFFF" : theme.secondaryText
                                }
                            }

                            Text {
                                text: modelData
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 12
                                color: theme.primaryText
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                        }

                        HoverHandler { id: optHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: tutEngine.answerPrediction(index) }
                    }
                }
            }

            // ── Live Goal Tracker (when currentStep.type === "manipulate") ──────
            Rectangle {
                visible: tutEngine.currentStep && tutEngine.currentStep.type === "manipulate"
                width: parent.width
                height: 38
                radius: 6
                color: tutEngine.stepSatisfied ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#222428" : "#F4F6F8")
                border.color: tutEngine.stepSatisfied ? "#30D158" : theme.accent
                border.width: 1

                Row {
                    anchors { left: parent.left; right: parent.right; margins: 12; verticalCenter: parent.verticalCenter }
                    spacing: 8

                    Codicon {
                        icon: tutEngine.stepSatisfied ? "check" : "target"
                        iconSize: 14
                        iconColor: tutEngine.stepSatisfied ? "#30D158" : theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: tutEngine.stepSatisfied
                            ? "Goal Satisfied! " + (tutEngine.currentStep.conditionName || "")
                            : "Awaiting Action: " + (tutEngine.currentStep.conditionName || "")
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: tutEngine.stepSatisfied ? "#30D158" : theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Feedback Message Bar
            Rectangle {
                visible: tutEngine.feedbackText.length > 0
                width: parent.width
                implicitHeight: fbText.implicitHeight + 14
                radius: 5
                color: tutEngine.stepSatisfied ? (theme.isDark ? "#143820" : "#E6F4EA") : (theme.isDark ? "#2D2619" : "#FFF8E1")
                border.color: tutEngine.stepSatisfied ? "#30D158" : "#FF9F0A"
                border.width: 1

                Text {
                    id: fbText
                    anchors { left: parent.left; right: parent.right; margins: 10; verticalCenter: parent.verticalCenter }
                    text: tutEngine.feedbackText
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 12
                    color: tutEngine.stepSatisfied ? (theme.isDark ? "#4CD964" : "#1B5E20") : (theme.isDark ? "#FFD60A" : "#F57F17")
                    wrapMode: Text.WordWrap
                }
            }

            // ── Footer Navigation Buttons ────────────────────────────────────
            RowLayout {
                width: parent.width

                // Previous Step Button
                Rectangle {
                    width: 90
                    height: 32
                    radius: 5
                    color: prevHov.hovered ? (theme.isDark ? "#2F3237" : "#E5E5E5") : (theme.isDark ? "#25282C" : "#EEEEEE")
                    border.color: theme.borderColor
                    border.width: 1
                    visible: tutEngine.currentStepIndex > 0

                    Text {
                        anchors.centerIn: parent
                        text: "← Previous"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.primaryText
                    }

                    HoverHandler { id: prevHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: tutEngine.prevStep() }
                }

                Item { Layout.fillWidth: true }

                // XP Pill
                Row {
                    spacing: 6
                    Layout.alignment: Qt.AlignVCenter
                    Rectangle {
                        width: 8
                        height: 8
                        radius: 4
                        color: "#FFD60A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "+" + (tutEngine.activeTutorial ? tutEngine.activeTutorial.xpAward : 100) + " XP"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: theme.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Next Step Button
                Rectangle {
                    width: 110
                    height: 32
                    radius: 5
                    color: tutEngine.stepSatisfied
                        ? (nextHov.hovered ? "#0071E3" : theme.accent)
                        : (theme.isDark ? "#2A2D32" : "#E0E0E0")

                    Text {
                        anchors.centerIn: parent
                        text: (tutEngine.currentStepIndex === (tutEngine.activeTutorial ? tutEngine.activeTutorial.steps.length - 1 : 0))
                            ? "Complete ✓" : "Next Step →"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: tutEngine.stepSatisfied ? "#FFFFFF" : theme.secondaryText
                    }

                    HoverHandler { id: nextHov; cursorShape: tutEngine.stepSatisfied ? Qt.PointingHandCursor : Qt.ArrowCursor }
                    TapHandler {
                        enabled: tutEngine.stepSatisfied
                        onTapped: tutEngine.nextStep()
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ModeHeaderBar.qml — Top navigation bar with 3 application modes [DESIGN | LEARN | CHALLENGE],
// XP mastery progress indicator, and tutorial controls.
Rectangle {
    id: root
    width: parent.width
    height: 40
    color: theme.isDark ? "#18191B" : "#F0F2F5"
    border.color: theme.borderColor
    border.width: 0
    clip: true
    z: 95

    property var tutEngine: null

    // Bottom separator line
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: theme.isDark ? "#28292D" : "#E2E5E9"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        // ── Brand Logo ────────────────────────────────────────────────────────
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                width: 18
                height: 18
                radius: 4
                color: theme.accent
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.centerIn: parent
                    text: "O3"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 10
                    font.weight: Font.Black
                    color: "#FFFFFF"
                }
            }

            Text {
                text: "OVERTUNE 3"
                font.family: "Stack Sans Headline"
                font.pixelSize: 12
                font.weight: Font.Bold
                color: theme.primaryText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── 3-Mode Segmented Switcher [ DESIGN | LEARN | CHALLENGE ] ──────────
        Rectangle {
            height: 28
            width: modeRow.implicitWidth + 8
            radius: 5
            color: theme.isDark ? "#222327" : "#E6E8EB"
            Layout.alignment: Qt.AlignVCenter

            Row {
                id: modeRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: [
                        { label: "DESIGN",    icon: "tools",        index: 0 },
                        { label: "LEARN",     icon: "mortar-board", index: 1 },
                        { label: "CHALLENGE", icon: "beaker",       index: 2 }
                    ]
                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        readonly property bool active: tutEngine && tutEngine.currentMode === index
                        width: modeBtnRow.implicitWidth + 16
                        height: 24
                        radius: 4
                        color: active
                            ? (index === 2 ? "#FF9F0A" : theme.accent)
                            : (btnHov.hovered ? (theme.isDark ? "#2D2E33" : "#DDE0E5") : "transparent")

                        Row {
                            id: modeBtnRow
                            anchors.centerIn: parent
                            spacing: 6

                            Codicon {
                                icon: modelData.icon
                                iconSize: 12
                                iconColor: parent.parent.active ? "#FFFFFF" : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.label
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 11
                                font.weight: parent.parent.active ? Font.Bold : Font.DemiBold
                                color: parent.parent.active ? "#FFFFFF" : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler { id: btnHov; cursorShape: Qt.PointingHandCursor }
                        TapHandler { onTapped: if (tutEngine) tutEngine.setMode(index) }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // ── Center Context Badges ─────────────────────────────────────────────
        // In LEARN mode: Tutorial Dropdown Button & Instructor Record Toggle
        Row {
            visible: tutEngine && tutEngine.currentMode === 1
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            // Tutorial Picker Pill
            Rectangle {
                height: 26
                width: tutPillRow.implicitWidth + 16
                radius: 4
                color: theme.isDark ? "#28292E" : "#E0E3E8"
                border.color: theme.accent
                border.width: 1

                Row {
                    id: tutPillRow
                    anchors.centerIn: parent
                    spacing: 6
                    Codicon { icon: "book"; iconSize: 11; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: tutEngine && tutEngine.activeTutorial ? tutEngine.activeTutorial.title : "Select Tutorial"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Codicon { icon: "chevron-down"; iconSize: 10; iconColor: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter }
                }

                HoverHandler { id: tpHov; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: tutMenu.open() }

                Menu {
                    id: tutMenu
                    y: parent.height + 4
                    Repeater {
                        model: tutEngine ? tutEngine.tutorials : []
                        delegate: MenuItem {
                            required property int index
                            required property var modelData
                            text: "0" + (index + 1) + ". " + modelData.title + " (" + modelData.difficulty + ")"
                            onTriggered: tutEngine.selectTutorial(index)
                        }
                    }
                }
            }

            // Instructor Record Toggle
            Rectangle {
                height: 26
                width: recRow.implicitWidth + 14
                radius: 4
                color: (tutEngine && tutEngine.isRecording) ? "#FF453A" : (theme.isDark ? "#28292E" : "#E0E3E8")

                Row {
                    id: recRow
                    anchors.centerIn: parent
                    spacing: 5
                    Rectangle {
                        width: 7
                        height: 7
                        radius: 3.5
                        color: (tutEngine && tutEngine.isRecording) ? "#FFFFFF" : "#FF453A"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: (tutEngine && tutEngine.isRecording) ? "Recording..." : "Record Tutorial"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: (tutEngine && tutEngine.isRecording) ? "#FFFFFF" : theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                HoverHandler { id: recHov; cursorShape: Qt.PointingHandCursor }
                TapHandler {
                    onTapped: {
                        if (tutEngine) {
                            if (tutEngine.isRecording) {
                                tutEngine.stopRecording()
                            } else {
                                tutEngine.startRecording()
                            }
                        }
                    }
                }
            }
        }

        // ── Right Side: Progressive Mastery Gamification Bar ──────────────────
        Row {
            spacing: 10
            Layout.alignment: Qt.AlignVCenter

            // Mastery progress dots
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: 5
                    delegate: Rectangle {
                        required property int index
                        width: 6
                        height: 6
                        radius: 3
                        color: (index < 3) ? "#30D158" : (theme.isDark ? "#3E4148" : "#C5CAD2")
                    }
                }
            }

            // XP Pill
            Rectangle {
                height: 22
                width: xpRow.implicitWidth + 14
                radius: 11
                color: theme.isDark ? "#25272B" : "#E4E7EB"

                Row {
                    id: xpRow
                    anchors.centerIn: parent
                    spacing: 5

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#FFD60A"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "XP " + (tutEngine ? tutEngine.userXp : 340) + " / " + (tutEngine ? tutEngine.maxXp : 500)
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: theme.primaryText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Unlocked Badge Pill
            Rectangle {
                height: 22
                width: badgeRow.implicitWidth + 14
                radius: 11
                color: theme.isDark ? "#1C2D42" : "#E1EFFF"
                border.color: theme.accent
                border.width: 1

                Row {
                    id: badgeRow
                    anchors.centerIn: parent
                    spacing: 5

                    Codicon {
                        icon: "verified"
                        iconSize: 11
                        iconColor: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: tutEngine ? tutEngine.userBadge : "Pole Explorer"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}

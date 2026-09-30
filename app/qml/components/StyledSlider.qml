import QtQuick
import QtQuick.Controls

// StyledSlider.qml — compact slider with adaptive value label, manual numeric entry and pointing hand cursor
Item {
    id: root
    implicitWidth: 200
    implicitHeight: 32
    height: parent ? parent.height : implicitHeight
    width: parent ? parent.width : implicitWidth
    clip: true

    property alias from:  sl.from
    property alias to:    sl.to
    property alias value: sl.value
    property alias stepSize: sl.stepSize
    property alias pressed: sl.pressed
    property string valueSuffix: ""
    property int   valueDecimals: 1
    property bool  allowManualEntry: true

    readonly property real valueLabelWidth: {
        const sample = Number(sl.value).toFixed(valueDecimals) + valueSuffix
        return Math.min(Math.max(48, sample.length * 7.5 + 8), Math.max(48, width * 0.42))
    }

    signal moved()
    signal manualValueEntered(real val)

    Slider {
        id: sl
        from: 0
        to: 1
        onMoved: root.moved()
        anchors {
            left: parent.left
            right: valBox.left
            rightMargin: 6
            top: parent.top
            bottom: parent.bottom
        }
        enabled: root.width > 48 && (to > from)

        background: Rectangle {
            implicitWidth: 80
            implicitHeight: 4
            x: sl.leftPadding
            y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: Math.max(0, sl.availableWidth)
            height: 4
            radius: 2
            color: theme.surfaceHigh

            Rectangle {
                width:  Math.max(0, Math.min(1, sl.visualPosition)) * parent.width
                height: parent.height
                radius: 2
                color: theme.accent
            }
        }

        handle: Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
            y: sl.topPadding + sl.availableHeight / 2 - height / 2
            width: 16
            height: 16
            radius: 8
            color: "#FFFFFF"
            border.color: sl.pressed ? theme.accent : theme.borderColor
            border.width: sl.pressed ? 2 : 1
            visible: sl.availableWidth > 16
            scale: sl.pressed ? 1.15 : (sliderHov.hovered ? 1.08 : 1.0)
            Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
        }

        HoverHandler {
            id: sliderHov
            cursorShape: sl.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    // Interactive Manual Entry Box
    Rectangle {
        id: valBox
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: root.valueLabelWidth
        height: 22
        radius: 4
        color: valInput.activeFocus 
                ? (theme.isDark ? "#1C2D42" : "#E1EFFF")
                : (valBoxMouse.containsMouse ? (theme.isDark ? "#25272B" : "#E4E7EB") : "transparent")
        border.color: valInput.activeFocus ? theme.accent : (valBoxMouse.containsMouse ? theme.borderColor : "transparent")
        border.width: 1

        TextInput {
            id: valInput
            anchors.fill: parent
            anchors.leftMargin: 3
            anchors.rightMargin: 3
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignRight
            font.family: "Stack Sans Headline"
            font.pixelSize: root.width < 110 ? 10 : 11
            font.weight: Font.DemiBold
            color: theme.accent
            selectByMouse: true
            clip: true

            property bool userEditing: false

            text: userEditing ? text : (Number(sl.value).toFixed(root.valueDecimals) + root.valueSuffix)

            onActiveFocusChanged: {
                if (activeFocus) {
                    userEditing = true
                    text = String(sl.value)
                    selectAll()
                } else {
                    commitInput()
                    userEditing = false
                }
            }

            onAccepted: {
                commitInput()
                valInput.focus = false
            }

            function commitInput() {
                const cleaned = text.toString().replace(/[^0-9.-]/g, "")
                const num = parseFloat(cleaned)
                if (!isNaN(num) && isFinite(num)) {
                    const clamped = Math.max(sl.from, Math.min(sl.to, num))
                    sl.value = clamped
                    root.manualValueEntered(clamped)
                }
            }
        }

        MouseArea {
            id: valBoxMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            onClicked: {
                valInput.forceActiveFocus()
            }
        }

        ToolTip.visible: valBoxMouse.containsMouse && !valInput.activeFocus
        ToolTip.text: "Click to enter exact value manually"
        ToolTip.delay: 350
    }
}

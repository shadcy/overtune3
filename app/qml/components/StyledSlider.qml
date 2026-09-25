import QtQuick
import QtQuick.Controls

// StyledSlider.qml — compact slider with adaptive value label
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

    readonly property real valueLabelWidth: {
        const sample = Number(sl.value).toFixed(valueDecimals) + valueSuffix
        // Approximate: ~7px per char at 12px Inter, clamp for overflow safety
        return Math.min(Math.max(40, sample.length * 7.2), Math.max(40, width * 0.38))
    }

    signal moved()

    Slider {
        id: sl
        from: 0
        to: 1
        onMoved: root.moved()
        anchors {
            left: parent.left
            right: valText.left
            rightMargin: 6
            top: parent.top
            bottom: parent.bottom
        }
        // Prevent zero-width slider crash / NaN visualPosition
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
        }
    }

    Text {
        id: valText
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        text: Number(sl.value).toFixed(root.valueDecimals) + root.valueSuffix
        font.family: "Stack Sans Headline"
        font.pixelSize: root.width < 110 ? 10 : 12
        font.weight: Font.Medium
        color: theme.accent
        width: root.valueLabelWidth
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
    }
}

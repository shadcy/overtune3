import QtQuick

// ImpulseStepPlot.qml — Impulse or step response time-domain plot
Item {
    id: root
    implicitWidth: 300
    implicitHeight: 220

    property int mode: 0   // 0=Impulse, 1=Step
    property var points: []
    property string curveColor: mode === 0 ? "#BF5AF2" : "#FF375F"

    readonly property real marginLeft:   48
    readonly property real marginRight:  16
    readonly property real marginTop:    16
    readonly property real marginBottom: 32

    function refreshPoints() {
        points = mode === 0 ? filterEngine.impulseData : filterEngine.stepData
    }

    function schedulePaint() {
        if (canvas.available)
            canvas.requestPaint()
        else
            paintRetry.restart()
    }

    Rectangle {
        anchors.fill: parent
        color: theme.surface
        radius: 10
        border.color: theme.borderColor
        border.width: 1
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.Image
        renderStrategy: Canvas.Cooperative

        onAvailableChanged: {
            if (available) {
                root.refreshPoints()
                requestPaint()
            }
        }

        onPaint: {
            const ctx = getContext("2d")
            if (!ctx)
                return

            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            const mL = root.marginLeft
            const mT = root.marginTop
            const pW = width  - mL - root.marginRight
            const pH = height - mT - root.marginBottom
            const pts = root.points
            const n = pts ? pts.length : 0

            if (n < 2 || pW <= 1 || pH <= 1)
                return

            let yMin = Infinity
            let yMax = -Infinity
            for (let i = 0; i < n; ++i) {
                const yv = Number(pts[i]["y"])
                if (yv < yMin) yMin = yv
                if (yv > yMax) yMax = yv
            }
            const margin = Math.max(0.05, (yMax - yMin) * 0.1)
            yMin -= margin
            yMax += margin
            const yRange = (yMax - yMin) || 1
            const xMax = Math.max(1, Number(pts[n - 1]["x"]))

            function toX(x) { return mL + (Number(x) / xMax) * pW }
            function toY(y) { return mT + (1.0 - (Number(y) - yMin) / yRange) * pH }

            ctx.strokeStyle = theme.plotGrid
            ctx.lineWidth = 1
            const zy = toY(0)
            if (zy > mT && zy < mT + pH) {
                ctx.beginPath()
                ctx.moveTo(mL, zy)
                ctx.lineTo(mL + pW, zy)
                ctx.stroke()
            }

            ctx.fillStyle = theme.secondaryText
            ctx.font = "10px sans-serif"
            ctx.textAlign = "right"
            ctx.textBaseline = "middle"
            for (let i = 0; i <= 4; ++i) {
                const frac = i / 4
                const v = yMin + frac * yRange
                const y = mT + (1.0 - frac) * pH
                ctx.fillText(v.toFixed(2), mL - 6, y)
            }

            ctx.textAlign = "center"
            ctx.textBaseline = "top"
            for (let i = 0; i <= 4; ++i) {
                const x = mL + (i / 4) * pW
                ctx.fillText(String(Math.round(xMax * i / 4)), x, mT + pH + 6)
            }
            ctx.fillText("Samples", mL + pW / 2, mT + pH + 20)

            ctx.lineWidth = 2
            ctx.strokeStyle = root.curveColor
            ctx.lineJoin = "round"
            ctx.lineCap = "round"
            ctx.beginPath()
            ctx.moveTo(toX(pts[0]["x"]), toY(pts[0]["y"]))
            for (let i = 1; i < n; ++i)
                ctx.lineTo(toX(pts[i]["x"]), toY(pts[i]["y"]))
            ctx.stroke()
        }
    }

    Timer {
        id: paintRetry
        interval: 50
        repeat: false
        onTriggered: root.schedulePaint()
    }

    Timer {
        interval: 120
        running: true
        repeat: false
        onTriggered: {
            root.refreshPoints()
            root.schedulePaint()
        }
    }

    Connections {
        target: filterEngine
        function onResultsChanged() {
            root.refreshPoints()
            root.schedulePaint()
        }
    }

    Connections {
        target: theme
        function onThemeModeChanged() { root.schedulePaint() }
    }

    Component.onCompleted: {
        refreshPoints()
        schedulePaint()
    }

    onModeChanged: {
        refreshPoints()
        schedulePaint()
    }
    onVisibleChanged: { if (visible) schedulePaint() }
    onWidthChanged:  schedulePaint()
    onHeightChanged: schedulePaint()
    onPointsChanged: schedulePaint()
}

import QtQuick

// SignalPlot.qml — Waveform plot for simulation (input/output)
Item {
    id: root
    implicitWidth: 600
    implicitHeight: 300

    property var  inputData:  []
    property var  outputData: []
    property bool showOutput: false

    readonly property real marginLeft:   48
    readonly property real marginRight:  16
    readonly property real marginTop:    16
    readonly property real marginBottom: 32

    function refreshData() {
        inputData = simulation.inputSignal
        outputData = simulation.outputSignal
        showOutput = outputData && outputData.length > 0
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
                root.refreshData()
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
            const pts = root.inputData
            const n = pts ? pts.length : 0

            if (n < 2 || pW <= 1 || pH <= 1)
                return

            const xMax = Math.max(1, Number(pts[n - 1]["x"]))
            const yMin = -1.1
            const yMax = 1.1
            const yRange = yMax - yMin

            function toX(x) { return mL + (Number(x) / xMax) * pW }
            function toY(y) { return mT + (1.0 - (Number(y) - yMin) / yRange) * pH }

            ctx.strokeStyle = theme.plotGrid
            ctx.lineWidth = 1
            const zy = toY(0)
            ctx.beginPath()
            ctx.moveTo(mL, zy)
            ctx.lineTo(mL + pW, zy)
            ctx.stroke()

            ctx.lineWidth = 1.5
            ctx.strokeStyle = theme.accent
            ctx.lineJoin = "round"
            ctx.beginPath()
            ctx.moveTo(toX(pts[0]["x"]), toY(pts[0]["y"]))
            for (let i = 1; i < n; ++i)
                ctx.lineTo(toX(pts[i]["x"]), toY(pts[i]["y"]))
            ctx.stroke()

            if (root.showOutput && root.outputData && root.outputData.length > 1) {
                const opts = root.outputData
                ctx.lineWidth = 1.5
                ctx.strokeStyle = "#30D158"
                ctx.beginPath()
                ctx.moveTo(toX(opts[0]["x"]), toY(opts[0]["y"]))
                for (let i = 1; i < opts.length; ++i)
                    ctx.lineTo(toX(opts[i]["x"]), toY(opts[i]["y"]))
                ctx.stroke()
            }

            ctx.fillStyle = theme.accent
            ctx.fillRect(mL + 4, mT + 8, 20, 3)
            ctx.fillStyle = theme.primaryText
            ctx.font = "10px sans-serif"
            ctx.textAlign = "left"
            ctx.textBaseline = "middle"
            ctx.fillText("Input", mL + 28, mT + 10)
            if (root.showOutput) {
                ctx.fillStyle = "#30D158"
                ctx.fillRect(mL + 74, mT + 8, 20, 3)
                ctx.fillStyle = theme.primaryText
                ctx.fillText("Output", mL + 98, mT + 10)
            }
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
            root.refreshData()
            root.schedulePaint()
        }
    }

    Connections {
        target: simulation
        function onDataChanged() {
            root.refreshData()
            root.schedulePaint()
        }
    }

    Connections {
        target: theme
        function onThemeModeChanged() { root.schedulePaint() }
    }

    Component.onCompleted: {
        refreshData()
        schedulePaint()
    }

    onVisibleChanged: { if (visible) schedulePaint() }
    onWidthChanged:  schedulePaint()
    onHeightChanged: schedulePaint()
}

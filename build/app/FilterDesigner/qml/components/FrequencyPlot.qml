import QtQuick
import QtQuick.Controls

// FrequencyPlot.qml — Interactive frequency response plot (Canvas)
Item {
    id: root
    implicitWidth: 600
    implicitHeight: 400

    property int    displayMode: 0   // 0=Magnitude, 1=Phase, 2=Group Delay
    property double sampleRate: filterEngine.sampleRate
    property double cutoffFreq: filterEngine.cutoffFreq
    property double cutoffFreq2: filterEngine.cutoffFreq2
    property bool   isBandFilter: filterEngine.filterType >= 2
    property var    points: []

    readonly property real marginLeft:   56
    readonly property real marginRight:  16
    readonly property real marginTop:    16
    readonly property real marginBottom: 40
    readonly property real plotW: Math.max(1, width  - marginLeft - marginRight)
    readonly property real plotH: Math.max(1, height - marginTop  - marginBottom)

    property real yMin: -100
    property real yMax: 10

    function refreshPoints() {
        if (displayMode === 0) {
            points = filterEngine.magnitudeData
            yMin = -100
            yMax = 10
        } else if (displayMode === 1) {
            points = filterEngine.phaseData
            let minP = 0, maxP = 0
            if (points && points.length > 0) {
                minP = Number(points[0]["y"])
                maxP = minP
                for (let i = 1; i < points.length; ++i) {
                    const y = Number(points[i]["y"])
                    if (y < minP) minP = y
                    if (y > maxP) maxP = y
                }
            }
            yMin = Math.min(-90, Math.floor((minP - 15) / 45) * 45)
            yMax = Math.max(0,   Math.ceil((maxP + 15) / 45) * 45)
        } else {
            points = filterEngine.groupDelayData
            let maxGd = 10
            if (points && points.length > 0) {
                for (let i = 0; i < points.length; ++i) {
                    const y = Number(points[i]["y"])
                    if (y > maxGd) maxGd = y
                }
            }
            yMin = 0
            yMax = Math.max(5, Math.ceil(maxGd * 1.25 / 5) * 5)
        }
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

    Rectangle {
        x: root.marginLeft
        y: root.marginTop
        width: root.plotW
        height: root.plotH
        color: theme.surfaceHigh
        radius: 6
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
            const pW = root.plotW
            const pH = root.plotH
            const nyquist = root.sampleRate / 2.0
            const pts = root.points
            const mode = root.displayMode
            const yMin = root.yMin
            const yMax = root.yMax
            const yRange = (yMax - yMin) || 1

            if (pW <= 1 || pH <= 1)
                return

            function freqToX(f) {
                if (!(f > 0))
                    return 0
                return (Math.log(f) / Math.LN10 - 0) /
                       (Math.log(nyquist) / Math.LN10 - 0) * pW
            }

            function valToY(v) {
                return mT + ((yMax - v) / yRange) * pH
            }

            function formatFreq(f) {
                if (f >= 1000)
                    return (f / 1000) + "k"
                return String(f)
            }

            function strokeDash(x1, y1, x2, y2, dashLen, gapLen) {
                const dx = x2 - x1
                const dy = y2 - y1
                const len = Math.sqrt(dx * dx + dy * dy)
                if (len < 1)
                    return
                const ux = dx / len
                const uy = dy / len
                let pos = 0
                let draw = true
                ctx.beginPath()
                while (pos < len) {
                    const seg = Math.min(draw ? dashLen : gapLen, len - pos)
                    const xa = x1 + ux * pos
                    const ya = y1 + uy * pos
                    const xb = x1 + ux * (pos + seg)
                    const yb = y1 + uy * (pos + seg)
                    if (draw) {
                        ctx.moveTo(xa, ya)
                        ctx.lineTo(xb, yb)
                    }
                    pos += seg
                    draw = !draw
                }
                ctx.stroke()
            }

            // Grid
            ctx.strokeStyle = theme.plotGrid
            ctx.lineWidth = 1
            const yGridCount = 8
            for (let i = 0; i <= yGridCount; ++i) {
                const frac = i / yGridCount
                const y = mT + frac * pH
                ctx.beginPath()
                ctx.moveTo(mL, y)
                ctx.lineTo(mL + pW, y)
                ctx.stroke()

                const val = yMax - frac * yRange
                ctx.fillStyle = theme.secondaryText
                ctx.font = "11px 'Stack Sans Headline', sans-serif"
                ctx.textAlign = "right"
                ctx.textBaseline = "middle"
                ctx.fillText(val.toFixed(0), mL - 8, y)
            }

            ctx.textAlign = "center"
            ctx.textBaseline = "top"
            const decades = [1, 10, 100, 1000, 10000, 100000]
            for (let d = 0; d < decades.length; ++d) {
                const freq = decades[d]
                if (freq < 1 || freq > nyquist)
                    continue
                const x = mL + freqToX(freq)
                ctx.strokeStyle = theme.plotGrid
                ctx.beginPath()
                ctx.moveTo(x, mT)
                ctx.lineTo(x, mT + pH)
                ctx.stroke()
                ctx.fillStyle = theme.secondaryText
                ctx.fillText(formatFreq(freq), x, mT + pH + 6)
            }

            ctx.fillStyle = theme.secondaryText
            ctx.font = "11px 'Stack Sans Headline', sans-serif"
            ctx.fillText("Frequency (Hz)", mL + pW / 2, mT + pH + 24)

            ctx.save()
            ctx.translate(14, mT + pH / 2)
            ctx.rotate(-Math.PI / 2)
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"
            const yLabel = mode === 0 ? "Magnitude (dB)"
                         : mode === 1 ? "Phase (°)"
                                      : "Group Delay (samples)"
            ctx.fillText(yLabel, 0, 0)
            ctx.restore()

            // -3 dB reference
            if (mode === 0) {
                const y3 = valToY(-3.0)
                if (y3 > mT && y3 < mT + pH) {
                    ctx.strokeStyle = "#FF9F0A"
                    ctx.lineWidth = 1
                    strokeDash(mL, y3, mL + pW, y3, 4, 4)
                    ctx.fillStyle = "#FF9F0A"
                    ctx.font = "10px 'Stack Sans Headline', sans-serif"
                    ctx.textAlign = "left"
                    ctx.textBaseline = "bottom"
                    ctx.fillText("-3 dB", mL + 4, y3 - 2)
                }
            }

            // Response curve
            const n = pts ? pts.length : 0
            if (n > 1) {
                const curve = root.curveColor()

                if (mode === 0) {
                    ctx.beginPath()
                    let fx0 = mL + freqToX(Number(pts[0]["x"]))
                    let fy0 = Math.max(mT, Math.min(mT + pH, valToY(Number(pts[0]["y"]))))
                    ctx.moveTo(fx0, fy0)
                    for (let i = 1; i < n; ++i) {
                        const fx = mL + freqToX(Number(pts[i]["x"]))
                        const fy = Math.max(mT, Math.min(mT + pH, valToY(Number(pts[i]["y"]))))
                        ctx.lineTo(fx, fy)
                    }
                    const fxEnd = mL + freqToX(Number(pts[n - 1]["x"]))
                    ctx.lineTo(fxEnd, mT + pH)
                    ctx.lineTo(fx0, mT + pH)
                    ctx.closePath()
                    ctx.fillStyle = "rgba(10, 132, 255, 0.14)"
                    ctx.fill()
                }

                ctx.lineWidth = 2.5
                ctx.strokeStyle = curve
                ctx.lineJoin = "round"
                ctx.lineCap = "round"
                ctx.beginPath()
                for (let i = 0; i < n; ++i) {
                    const fx = mL + freqToX(Number(pts[i]["x"]))
                    const fy = Math.max(mT, Math.min(mT + pH, valToY(Number(pts[i]["y"]))))
                    if (i === 0)
                        ctx.moveTo(fx, fy)
                    else
                        ctx.lineTo(fx, fy)
                }
                ctx.stroke()
            }

            function drawCutoffHandle(freq, color) {
                if (!(freq > 0) || freq >= nyquist)
                    return
                const x = mL + freqToX(freq)
                ctx.strokeStyle = color
                ctx.lineWidth = 1.5
                strokeDash(x, mT, x, mT + pH, 5, 3)
                ctx.fillStyle = color
                ctx.beginPath()
                ctx.arc(x, mT + pH * 0.25, 6, 0, 2 * Math.PI)
                ctx.fill()
                ctx.font = "bold 11px sans-serif"
                ctx.textAlign = "center"
                ctx.textBaseline = "bottom"
                ctx.fillText(formatFreq(Math.round(freq)), x, mT + pH * 0.25 - 10)
            }

            drawCutoffHandle(root.cutoffFreq, "#0A84FF")
            if (root.isBandFilter)
                drawCutoffHandle(root.cutoffFreq2, "#30D158")
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
        function onSpecChanged() {
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

    onVisibleChanged:     { if (visible) schedulePaint() }
    onWidthChanged:       schedulePaint()
    onHeightChanged:      schedulePaint()
    onDisplayModeChanged: {
        refreshPoints()
        schedulePaint()
    }
    onPointsChanged:      schedulePaint()

    property bool draggingCutoff:  false
    property bool draggingCutoff2: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        z: 2

        function xToFreq(mx) {
            const pW = root.plotW
            const nyquist = root.sampleRate / 2.0
            const norm = (mx - root.marginLeft) / pW
            if (norm < 0 || norm > 1)
                return -1
            return Math.pow(10, norm * (Math.log(nyquist) / Math.LN10))
        }

        function freqToCanvasX(f) {
            const pW = root.plotW
            const nyquist = root.sampleRate / 2.0
            if (!(f > 0))
                return root.marginLeft
            return root.marginLeft + (Math.log(f) / Math.LN10) /
                   (Math.log(nyquist) / Math.LN10) * pW
        }

        onPressed: function(mouse) {
            const x1 = freqToCanvasX(root.cutoffFreq)
            const x2 = freqToCanvasX(root.cutoffFreq2)
            if (Math.abs(mouse.x - x1) < 14)
                root.draggingCutoff = true
            else if (root.isBandFilter && Math.abs(mouse.x - x2) < 14)
                root.draggingCutoff2 = true
            cursorShape = Qt.SizeHorCursor
        }

        onReleased: {
            root.draggingCutoff  = false
            root.draggingCutoff2 = false
            cursorShape = Qt.ArrowCursor
        }

        onPositionChanged: function(mouse) {
            if (root.draggingCutoff) {
                const f = xToFreq(mouse.x)
                if (f > 1 && f < root.sampleRate / 2.0) {
                    filterEngine.cutoffFreq = Math.round(f * 10) / 10
                    root.schedulePaint()
                }
            } else if (root.draggingCutoff2) {
                const f = xToFreq(mouse.x)
                if (f > filterEngine.cutoffFreq && f < root.sampleRate / 2.0) {
                    filterEngine.cutoffFreq2 = Math.round(f * 10) / 10
                    root.schedulePaint()
                }
            }
        }

        onMouseXChanged: function() {
            if (!root.draggingCutoff && !root.draggingCutoff2) {
                const x1 = freqToCanvasX(root.cutoffFreq)
                const x2 = freqToCanvasX(root.cutoffFreq2)
                const nearHandle = Math.abs(mouseX - x1) < 14 ||
                    (root.isBandFilter && Math.abs(mouseX - x2) < 14)
                cursorShape = nearHandle ? Qt.SizeHorCursor : Qt.ArrowCursor
            }
        }
    }

    function curveColor() {
        if (displayMode === 0) return "#0A84FF"
        if (displayMode === 1) return "#FF9F0A"
        return "#30D158"
    }
}

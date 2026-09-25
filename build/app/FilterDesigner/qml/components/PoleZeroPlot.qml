import QtQuick

// PoleZeroPlot.qml — Z-plane pole-zero plot using Canvas
Item {
    id: root
    implicitWidth: 300
    implicitHeight: 300

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
            if (available)
                requestPaint()
        }

        onPaint: {
            const ctx = getContext("2d")
            if (!ctx)
                return

            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            const cx = width / 2
            const cy = height / 2
            const r  = Math.min(width, height) / 2 - 24
            if (r <= 5)
                return

            ctx.strokeStyle = theme.plotGrid
            ctx.lineWidth = 1
            ctx.beginPath(); ctx.moveTo(cx - r - 10, cy); ctx.lineTo(cx + r + 10, cy); ctx.stroke()
            ctx.beginPath(); ctx.moveTo(cx, cy - r - 10); ctx.lineTo(cx, cy + r + 10); ctx.stroke()

            ctx.strokeStyle = theme.borderColor
            ctx.lineWidth = 1.5
            ctx.beginPath()
            ctx.arc(cx, cy, r, 0, 2 * Math.PI)
            ctx.stroke()

            ctx.fillStyle = theme.secondaryText
            ctx.font = "10px sans-serif"
            ctx.textAlign = "left"
            ctx.textBaseline = "alphabetic"
            ctx.fillText("|z|=1", cx + r + 4, cy - 4)
            ctx.fillText("Re", cx + r + 4, cy + 14)
            ctx.fillText("Im", cx + 4, cy - r - 6)

            const pts = filterEngine.poleZeroData
            const n = pts ? pts.length : 0
            for (let i = 0; i < n; ++i) {
                const pt = pts[i]
                const px = cx + Number(pt["re"]) * r
                const py = cy - Number(pt["im"]) * r
                if (String(pt["kind"]) === "pole") {
                    ctx.strokeStyle = theme.danger
                    ctx.lineWidth = 2.5
                    const s = 7
                    ctx.beginPath(); ctx.moveTo(px - s, py - s); ctx.lineTo(px + s, py + s); ctx.stroke()
                    ctx.beginPath(); ctx.moveTo(px + s, py - s); ctx.lineTo(px - s, py + s); ctx.stroke()
                } else {
                    ctx.strokeStyle = theme.accent
                    ctx.lineWidth = 2.5
                    ctx.beginPath()
                    ctx.arc(px, py, 6, 0, 2 * Math.PI)
                    ctx.stroke()
                }
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
        onTriggered: root.schedulePaint()
    }

    Connections {
        target: filterEngine
        function onResultsChanged() { root.schedulePaint() }
    }

    Connections {
        target: theme
        function onThemeModeChanged() { root.schedulePaint() }
    }

    Component.onCompleted: schedulePaint()
    onVisibleChanged: { if (visible) schedulePaint() }
    onWidthChanged:  schedulePaint()
    onHeightChanged: schedulePaint()
}

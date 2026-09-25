import QtQuick

// ActivityIcon.qml — Canvas-drawn activity bar icons (no QtQuick.Shapes / SVG plugin)
Item {
    id: root
    implicitWidth: 22
    implicitHeight: 22

    property string iconName: "design"
    property color iconColor: "#CCCCCC"

    onIconNameChanged: canvas.requestPaint()
    onIconColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        renderTarget: Canvas.Image

        onAvailableChanged: if (available) requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            if (!ctx)
                return
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            const s = Math.min(width, height) / 24
            ctx.translate((width - 24 * s) / 2, (height - 24 * s) / 2)
            ctx.scale(s, s)
            ctx.fillStyle = root.iconColor
            ctx.strokeStyle = root.iconColor
            ctx.lineWidth = 1.6
            ctx.lineJoin = "round"
            ctx.lineCap = "round"

            switch (root.iconName) {
            case "design":
                // Wand / magic tip
                ctx.beginPath()
                ctx.moveTo(18.5, 3.5)
                ctx.lineTo(9.5, 12.5)
                ctx.lineTo(11.5, 14.5)
                ctx.lineTo(20.5, 5.5)
                ctx.closePath()
                ctx.fill()
                // Spark
                ctx.beginPath()
                ctx.moveTo(6, 3)
                ctx.lineTo(6.8, 5.2)
                ctx.lineTo(9, 6)
                ctx.lineTo(6.8, 6.8)
                ctx.lineTo(6, 9)
                ctx.lineTo(5.2, 6.8)
                ctx.lineTo(3, 6)
                ctx.lineTo(5.2, 5.2)
                ctx.closePath()
                ctx.fill()
                // Brush blob
                ctx.beginPath()
                ctx.arc(7.5, 16.5, 4.2, 0, Math.PI * 2)
                ctx.fill()
                break

            case "analysis-alt":
                // Window tile
                ctx.beginPath()
                roundRect(ctx, 2, 2, 9, 9, 2)
                ctx.fill()
                // Sync arrows
                ctx.beginPath()
                ctx.moveTo(20, 4)
                ctx.lineTo(17, 4)
                ctx.lineTo(17, 2)
                ctx.lineTo(13, 5)
                ctx.lineTo(17, 8)
                ctx.lineTo(17, 6)
                ctx.lineTo(20, 6)
                ctx.closePath()
                ctx.fill()
                ctx.beginPath()
                ctx.moveTo(7, 18)
                ctx.lineTo(4, 18)
                ctx.lineTo(4, 13)
                ctx.lineTo(2, 13)
                ctx.lineTo(2, 20)
                ctx.lineTo(7, 20)
                ctx.lineTo(7, 22)
                ctx.lineTo(11, 19)
                ctx.lineTo(7, 16)
                ctx.closePath()
                ctx.fill()
                // Circle
                ctx.beginPath()
                ctx.arc(17.5, 17.5, 4.2, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.arc(17.5, 17.5, 2.4, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
                break

            case "play":
                ctx.beginPath()
                ctx.moveTo(7, 5)
                ctx.lineTo(19, 12)
                ctx.lineTo(7, 19)
                ctx.closePath()
                ctx.fill()
                break

            case "export":
                ctx.beginPath()
                ctx.moveTo(12, 2)
                ctx.lineTo(21, 13)
                ctx.lineTo(15, 13)
                ctx.lineTo(15, 22)
                ctx.lineTo(9, 22)
                ctx.lineTo(9, 13)
                ctx.lineTo(3, 13)
                ctx.closePath()
                ctx.fill()
                break

            case "settings":
                // Gear
                ctx.translate(12, 12)
                for (let i = 0; i < 8; ++i) {
                    ctx.rotate(Math.PI / 4)
                    ctx.fillRect(-1.6, -10.5, 3.2, 5.5)
                }
                ctx.beginPath()
                ctx.arc(0, 0, 7.2, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "destination-out"
                ctx.beginPath()
                ctx.arc(0, 0, 3.2, 0, Math.PI * 2)
                ctx.fill()
                ctx.globalCompositeOperation = "source-over"
                break
            }
        }

        function roundRect(ctx, x, y, w, h, r) {
            ctx.moveTo(x + r, y)
            ctx.arcTo(x + w, y, x + w, y + h, r)
            ctx.arcTo(x + w, y + h, x, y + h, r)
            ctx.arcTo(x, y + h, x, y, r)
            ctx.arcTo(x, y, x + w, y, r)
            ctx.closePath()
        }
    }

    Component.onCompleted: canvas.requestPaint()
}

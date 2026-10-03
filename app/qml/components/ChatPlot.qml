import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property var artifacts: []
    property int mode: 0
    implicitHeight: 320
    Layout.fillWidth: true

    readonly property var modeNames: ["Magnitude", "Phase", "Delay", "Poles", "Impulse", "Step"]
    readonly property var modeUnits: ["dB · frequency (Hz)", "degrees · frequency (Hz)", "samples · frequency (Hz)", "z-plane · real and imaginary", "amplitude · sample index", "amplitude · sample index"]
    readonly property var colors: ["#0A84FF", "#FF375F", "#30D158", "#FF9F0A", "#BF5AF2"]

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: theme.isDark ? "#18181B" : "#FFFFFF"
        border.color: theme.borderColor
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Row {
                spacing: 7
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Codicon {
                    icon: root.artifacts.length > 1 ? "diff" : "graph"
                    iconSize: 15
                    iconColor: theme.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.artifacts.length > 1
                        ? "Calculated Comparison (" + root.artifacts.length + " variants)"
                        : (root.artifacts.length === 1 && root.artifacts[0].title ? root.artifacts[0].title : "Filter Analysis")
                    color: theme.primaryText
                    font.family: theme.headlineFont
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            SegmentedButton {
                model: root.modeNames
                currentIndex: root.mode
                Layout.preferredWidth: Math.min(420, Math.max(340, root.width - 220))
                Layout.minimumWidth: 320
                implicitHeight: 28
                onActivated: function(index) { root.mode = index; plot.requestPaint() }
            }
        }

        Canvas {
            id: plot
            Layout.fillWidth: true
            Layout.fillHeight: true
            antialiasing: true
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                const left = 52, right = width - 14, top = 12, bottom = height - 30
                const plotWidth = Math.max(1, right - left)
                const plotHeight = Math.max(1, bottom - top)
                ctx.font = "11px Inter"
                ctx.lineWidth = 1
                ctx.strokeStyle = theme.borderColor
                ctx.fillStyle = theme.secondaryText
                const frequencyMode = root.mode <= 2
                const rootMode = root.mode === 3
                const values = []
                let xMin = 0, xMax = 1, yMin = 0, yMax = 1
                let radius = 1.15
                const seriesFor = function(data) {
                    return frequencyMode
                        ? data.frequencyResponse.points
                        : (root.mode === 4 ? data.timeResponse.impulse : data.timeResponse.step)
                }
                if (rootMode) {
                    for (let ai = 0; ai < root.artifacts.length; ++ai) {
                        const roots = root.artifacts[ai].data.roots
                        for (let group = 0; group < 2; ++group) {
                            const list = group === 0 ? roots.poles : roots.zeros
                            for (let i = 0; i < list.length; ++i)
                                radius = Math.max(radius, Math.abs(Number(list[i][0])), Math.abs(Number(list[i][1])))
                        }
                    }
                    radius *= 1.12
                    xMin = -radius; xMax = radius; yMin = -radius; yMax = radius
                } else {
                    for (let ai = 0; ai < root.artifacts.length; ++ai) {
                        const points = seriesFor(root.artifacts[ai].data)
                        for (let i = 0; i < points.length; ++i) {
                            const x = Number(points[i][0])
                            const raw = frequencyMode ? points[i][root.mode + 1] : points[i][1]
                            if (raw === null || raw === undefined || !isFinite(x)) continue
                            const y = Number(raw)
                            if (!isFinite(y)) continue
                            if (frequencyMode && !(x > 0)) continue
                            values.push(y)
                            if (!frequencyMode) xMax = Math.max(xMax, x)
                        }
                    }
                    if (values.length < 2) return
                    if (frequencyMode) {
                        const first = root.artifacts[0].data.frequencyResponse.points
                        xMin = Math.max(1e-6, first.find(p => p[0] > 0)?.[0] || 1)
                        xMax = first[first.length - 1][0]
                        if (root.mode === 0) { yMin = -120; yMax = 12 }
                        else if (root.mode === 1) { yMin = -180; yMax = 180 }
                        else {
                            values.sort((a, b) => a - b)
                            yMin = values[Math.floor((values.length - 1) * 0.03)]
                            yMax = values[Math.floor((values.length - 1) * 0.97)]
                            const span = Math.max(1e-6, yMax - yMin)
                            yMin -= span * 0.08; yMax += span * 0.08
                        }
                    } else {
                        values.sort((a, b) => a - b)
                        yMin = values[Math.floor((values.length - 1) * 0.02)]
                        yMax = values[Math.floor((values.length - 1) * 0.98)]
                        const span = Math.max(1e-8, yMax - yMin)
                        yMin -= span * 0.1; yMax += span * 0.1
                    }
                    if (yMin === yMax) { yMin -= 1; yMax += 1 }
                }

                const xMap = function(x) {
                    if (rootMode) return (left + right) / 2 + x / radius * Math.min(plotWidth, plotHeight) / 2
                    if (frequencyMode) return left + (Math.log10(x) - Math.log10(xMin)) /
                        (Math.log10(xMax) - Math.log10(xMin)) * plotWidth
                    return left + (x - xMin) / (xMax - xMin) * plotWidth
                }
                const yMap = function(y) {
                    if (rootMode) return (top + bottom) / 2 - y / radius * Math.min(plotWidth, plotHeight) / 2
                    return top + (yMax - y) / (yMax - yMin) * plotHeight
                }

                ctx.textAlign = "right"; ctx.textBaseline = "middle"
                for (let i = 0; i <= 4; ++i) {
                    const y = top + plotHeight * i / 4
                    const v = rootMode ? radius - radius * 2 * i / 4 : yMax - (yMax - yMin) * i / 4
                    ctx.beginPath(); ctx.moveTo(left, y); ctx.lineTo(right, y); ctx.stroke()
                    ctx.fillText(v.toFixed(rootMode ? 1 : (root.mode === 2 ? 2 : 0)), left - 8, y)
                }

                ctx.textAlign = "center"; ctx.textBaseline = "top"
                for (let i = 0; i <= 4; ++i) {
                    const x = left + plotWidth * i / 4
                    ctx.beginPath(); ctx.moveTo(x, top); ctx.lineTo(x, bottom); ctx.stroke()
                    let label
                    if (rootMode) label = (radius - radius * 2 * i / 4).toFixed(1)
                    else if (frequencyMode) {
                        const hz = Math.pow(10, Math.log10(xMin) +
                            (Math.log10(xMax) - Math.log10(xMin)) * i / 4)
                        label = hz >= 1000 ? (hz / 1000).toPrecision(2) + " kHz" : Math.round(hz) + " Hz"
                    } else label = Math.round(xMax * i / 4).toString()
                    ctx.fillText(label, x, bottom + 7)
                }

                ctx.save()
                ctx.beginPath(); ctx.rect(left, top, plotWidth, plotHeight); ctx.clip()
                if (!rootMode) {
                    for (let ai = 0; ai < root.artifacts.length; ++ai) {
                        const points = seriesFor(root.artifacts[ai].data)
                        ctx.beginPath(); ctx.strokeStyle = root.colors[ai % root.colors.length]
                        ctx.lineWidth = ai === 0 ? 2.5 : 1.8
                        let started = false
                        for (let i = 0; i < points.length; ++i) {
                            const x = Number(points[i][0])
                            const raw = frequencyMode ? points[i][root.mode + 1] : points[i][1]
                            if (raw === null || raw === undefined || !isFinite(x) || !isFinite(Number(raw))) {
                                started = false
                                continue
                            }
                            if (frequencyMode && !(x > 0)) continue
                            const px = xMap(x), py = yMap(Number(raw))
                            if (!started) { ctx.moveTo(px, py); started = true }
                            else ctx.lineTo(px, py)
                        }
                        ctx.stroke()
                    }
                } else {
                    const centerX = (left + right) / 2, centerY = (top + bottom) / 2
                    const scale = Math.min(plotWidth, plotHeight) / (2 * radius)
                    ctx.save(); ctx.setLineDash([4, 4]); ctx.strokeStyle = theme.secondaryText; ctx.lineWidth = 1
                    ctx.beginPath(); ctx.arc(centerX, centerY, scale, 0, Math.PI * 2); ctx.stroke(); ctx.restore()
                    for (let ai = 0; ai < root.artifacts.length; ++ai) {
                        const roots = root.artifacts[ai].data.roots
                        ctx.strokeStyle = root.colors[ai % root.colors.length]
                        ctx.fillStyle = root.colors[ai % root.colors.length]
                        for (let group = 0; group < 2; ++group) {
                            const list = group === 0 ? roots.zeros : roots.poles
                            for (let i = 0; i < list.length; ++i) {
                                const x = xMap(Number(list[i][0])), y = yMap(Number(list[i][1]))
                                ctx.beginPath()
                                if (group === 0) { ctx.arc(x, y, 4.2, 0, Math.PI * 2); ctx.stroke() }
                                else { ctx.moveTo(x - 4, y - 4); ctx.lineTo(x + 4, y + 4); ctx.moveTo(x - 4, y + 4); ctx.lineTo(x + 4, y - 4); ctx.stroke() }
                            }
                        }
                    }
                }
                ctx.restore()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections {
                target: root
                function onArtifactsChanged() { plot.requestPaint() }
                function onModeChanged() { plot.requestPaint() }
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: 14
            Text {
                text: root.modeUnits[root.mode]
                color: theme.secondaryText
                font.family: theme.bodyFont
                font.pixelSize: 11
            }
            Text {
                visible: root.mode === 3
                text: "○ zeros    × poles    dashed circle: unit boundary"
                color: theme.secondaryText
                font.family: theme.bodyFont
                font.pixelSize: 11
            }
            Repeater {
                model: root.artifacts
                delegate: Row {
                    required property var modelData
                    required property int index
                    spacing: 5
                    Rectangle { width: 8; height: 8; radius: 4; color: root.colors[index % root.colors.length]; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: modelData.title
                        color: theme.secondaryText
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}

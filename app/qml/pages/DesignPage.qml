import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

// DesignPage.qml — Filter configuration + live frequency response (overflow-safe)
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property var typeNames:     ["Low Pass", "High Pass", "Band Pass", "Band Stop"]
    // IIR families, indexed like dsp::FilterResponse; FIR (5) has its own class toggle
    readonly property var iirFamilyNames: ["Butterworth", "Chebyshev I", "Chebyshev II", "Elliptic", "Bessel"]
    readonly property var iirFamilyHints: [
        "Maximally flat passband, moderate roll-off",
        "Equiripple passband, steeper roll-off than Butterworth",
        "Flat passband, equiripple stopband (inverse Chebyshev)",
        "Ripple in both bands, steepest transition for a given order",
        "Maximally flat group delay, gentlest roll-off"
    ]
    readonly property int firResponse: 5
    readonly property var firWindowNames: filterEngine.firWindowNames()
    // Typical first-sidelobe level and use, indexed like dsp::FirWindow
    readonly property var firWindowHints: [
        "Narrowest main lobe, -13 dB sidelobes",
        "-31 dB sidelobes, good general purpose",
        "-43 dB sidelobes, classic audio choice",
        "-58 dB sidelobes, wider transition",
        "Tunable: attenuation sets beta",
        "Triangular, -27 dB sidelobes",
        "-36 dB sidelobes, fast sidelobe decay",
        "-92 dB sidelobes, wide transition",
        "-93 dB sidelobes, smooth spectrum",
        "-98 dB sidelobes, widest 4-term lobe",
        "Flattest passband, very wide transition",
        "Tunable: sigma trades lobe width vs. sidelobes",
        "Tunable: alpha 0 = rectangular, 1 = Hann",
        "Sinc window, -26 dB sidelobes",
        "Sine window, -23 dB sidelobes",
        "Equal sidelobes at the chosen attenuation"
    ]
    readonly property bool shownUsesParam: shownIsFir && (shownFirWindow === 11 || shownFirWindow === 12)
    readonly property bool shownUsesAtten: shownIsFir && (shownFirWindow === 4 || shownFirWindow === 15)
    readonly property int shownResponse: hasPendingChanges ? pendingResponse : filterEngine.filterResponse
    readonly property int shownFirWindow: hasPendingChanges ? pendingFirWindow : filterEngine.firWindow
    readonly property bool shownIsFir: shownResponse === firResponse
    readonly property int shownType: hasPendingChanges ? pendingType : filterEngine.filterType
    readonly property int shownOrder: hasPendingChanges ? pendingOrder : filterEngine.order
    readonly property double shownRipple: hasPendingChanges ? pendingRipple : filterEngine.rippleDb
    readonly property double shownStopband: hasPendingChanges ? pendingStopband : filterEngine.stopbandDb
    readonly property bool isBand: shownType >= 2
    // High-pass / band-stop FIRs need an even order (odd tap count); the engine rounds up
    readonly property int shownEffectiveOrder: shownIsFir && (shownType === 1 || shownType === 3) && shownOrder % 2 !== 0
                                               ? shownOrder + 1 : shownOrder
    // What the cutoff slider means for the shown family (same targets the verifier checks)
    readonly property string cutoffMeaning: {
        if (shownIsFir) return "Cutoff = −6.02 dB (half-amplitude) point of the windowed sinc"
        switch (shownResponse) {
        case 1: case 3: return "Cutoff = passband edge (−" + shownRipple.toFixed(1) + " dB ripple limit)"
        case 2: return "Cutoff = stopband edge (−" + shownStopband.toFixed(0) + " dB)"
        default: return "Cutoff = −3.01 dB point"
        }
    }
    readonly property bool narrowLayout: width < 680
    readonly property int pageMargin: width < 700 ? 10 : 16

    // Last IIR family, restored when switching back from FIR
    property int lastIirResponse: filterEngine.filterResponse !== firResponse ? filterEngine.filterResponse : 0
    // Orders edited while pending, per class (-1 = use the engine's remembered order)
    property int pendingIirOrderMemo: -1
    property int pendingFirOrderMemo: -1

    property bool hasPendingChanges: false
    property int pendingType: filterEngine.filterType
    property int pendingResponse: filterEngine.filterResponse
    property int pendingOrder: filterEngine.order
    property double pendingSampleRate: filterEngine.sampleRate
    property double pendingCutoff: filterEngine.cutoffFreq
    property double pendingCutoff2: filterEngine.cutoffFreq2
    property double pendingRipple: filterEngine.rippleDb
    property double pendingStopband: filterEngine.stopbandDb
    property int pendingFirWindow: filterEngine.firWindow
    property double pendingFirWindowParam: filterEngine.firWindowParam

    function syncPendingWithEngine() {
        pendingType = filterEngine.filterType
        pendingResponse = filterEngine.filterResponse
        pendingOrder = filterEngine.order
        pendingSampleRate = filterEngine.sampleRate
        pendingCutoff = filterEngine.cutoffFreq
        pendingCutoff2 = filterEngine.cutoffFreq2
        pendingRipple = filterEngine.rippleDb
        pendingStopband = filterEngine.stopbandDb
        pendingFirWindow = filterEngine.firWindow
        pendingFirWindowParam = filterEngine.firWindowParam
        if (filterEngine.filterResponse !== firResponse)
            lastIirResponse = filterEngine.filterResponse
        pendingIirOrderMemo = -1
        pendingFirOrderMemo = -1
        hasPendingChanges = false
    }

    // Switch the pending design between IIR and FIR, keeping each class's order
    function selectFilterClass(fir) {
        if (fir === shownIsFir) return
        if (!hasPendingChanges) syncPendingWithEngine()
        if (fir) {
            pendingIirOrderMemo = pendingOrder
            lastIirResponse = pendingResponse
            pendingResponse = firResponse
            pendingOrder = pendingFirOrderMemo > 0 ? pendingFirOrderMemo : filterEngine.orderFor(firResponse)
        } else {
            pendingFirOrderMemo = pendingOrder
            pendingResponse = lastIirResponse
            pendingOrder = Math.min(pendingIirOrderMemo > 0 ? pendingIirOrderMemo : filterEngine.orderFor(lastIirResponse),
                                    filterEngine.maxOrder(lastIirResponse))
        }
        hasPendingChanges = true
    }

    function applyPendingChanges() {
        filterEngine.applySpec({
            filterType: pendingType,
            filterResponse: pendingResponse,
            order: pendingOrder,
            sampleRate: pendingSampleRate,
            cutoffFreq: pendingCutoff,
            cutoffFreq2: pendingCutoff2,
            rippleDb: pendingRipple,
            stopbandDb: pendingStopband,
            firWindow: pendingFirWindow,
            firWindowParam: pendingFirWindowParam
        })
        syncPendingWithEngine()
        if (freqPlot) {
            freqPlot.refreshPoints()
            freqPlot.schedulePaint()
            freqPlot.showPlotToast("Manual configuration applied")
        }
    }

    Connections {
        target: filterEngine
        function onSpecChanged() {
            if (!root.hasPendingChanges) {
                root.syncPendingWithEngine()
            }
        }
    }

    Component.onCompleted: syncPendingWithEngine()

    // Secondary caption under a control; collapses when hidden
    component Hint: Text {
        width: parent ? parent.width : implicitWidth
        height: visible ? implicitHeight : 0
        font.family: "Stack Sans Headline"
        font.pixelSize: 11
        color: theme.secondaryText
        wrapMode: Text.WordWrap
    }

    property alias freqPlot: freqPlot

    function setPlotMode(m) {
        if (freqPlot) freqPlot.displayMode = m
    }

    readonly property real configWidth: {
        const w = Math.min(360, Math.max(280, width * 0.28))
        return Math.min(w, Math.max(260, width - 320))
    }

    readonly property real configHeight: {
        const minPlot = 160
        const budget = Math.max(140, height - minPlot - pageMargin)
        return Math.min(budget, Math.max(160, Math.min(360, height * 0.4)))
    }

    // ── Config panel ──────────────────────────────────────────────────────────
    Item {
        id: configPanel
        x: 0
        y: 0
        width: root.narrowLayout ? root.width : root.configWidth
        height: root.narrowLayout ? root.configHeight : root.height
        z: 1
        clip: true

        Rectangle {
            anchors.fill: parent
            color: theme.sidebarBg
        }

        Rectangle {
            id: titleStrip
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 60
            color: "transparent"
            z: 2

            // Native Squircle Logo
            Item {
                id: logoSquircle
                anchors {
                    left: parent.left
                    leftMargin: 14
                    verticalCenter: parent.verticalCenter
                }
                width: 44
                height: 44

                Image {
                    anchors.fill: parent
                    source: "qrc:/FilterDesigner/icons/logo.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                ToolTip.visible: logoHover.hovered
                ToolTip.text: "Overtune 3 Studio"
                ToolTip.delay: 300

                HoverHandler {
                    id: logoHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        const w = Window.window
                        if (w && typeof w.showWhatsNew === "function") {
                            w.showWhatsNew()
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.borderColor
                opacity: 0.55
            }
        }

        Flickable {
            id: configFlick
            anchors {
                top: titleStrip.bottom
                left: parent.left
                right: parent.right
                bottom: stickyApplyBar.top
            }
            clip: true
            contentWidth: width
            contentHeight: configColumn.implicitHeight + 36
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick

            // Modern translucent custom scrollbar (eliminates stark white overflow bar)
            ScrollBar.vertical: ScrollBar {
                id: configScrollBar
                policy: configFlick.contentHeight > configFlick.height
                        ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                width: 6
                anchors.right: parent.right
                anchors.rightMargin: 2
                topPadding: 4
                bottomPadding: 4
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                color: configScrollBar.pressed ? theme.accent
                     : (configScrollBar.hovered ? (theme.isDark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.4))
                                                    : (theme.isDark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0, 0, 0, 0.18)))
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
                background: Item {
                    implicitWidth: 6
                }
            }

            Column {
                id: configColumn
                x: 14
                width: Math.max(0, configFlick.width - 28)
                spacing: 6
                topPadding: 10
                bottomPadding: 24

                Text {
                    width: parent.width
                    text: "Filter Configuration"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: theme.primaryText
                    wrapMode: Text.WordWrap
                }

                SectionHeader { text: "PRESET TEMPLATES"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Application"
                    StyledCombo {
                        id: appPresetCombo
                        width: parent.width
                        model: [
                            "Custom Specification",
                            "Audio Sub-Bass Cut (30 Hz HP)",
                            "Audio Bass Roll-Off (80 Hz HP)",
                            "Mains Hum Notch (50 Hz BS)",
                            "Mains Hum Notch (60 Hz BS)",
                            "Speech / Telecom (300-3.4k BP)",
                            "Anti-Aliasing Audio (20k LP)",
                            "Hi-Res Audio Filter (40k LP)",
                            "Ultrasonic Sensor (10k HP)"
                        ]
                        // Applied as one spec so no half-updated (invalid) design runs in between
                        readonly property var presetSpecs: [
                            null,
                            { filterType: 1, filterResponse: 0, order: 4, sampleRate: 48000, cutoffFreq: 30 },
                            { filterType: 1, filterResponse: 0, order: 3, sampleRate: 48000, cutoffFreq: 80 },
                            { filterType: 3, filterResponse: 3, order: 4, sampleRate: 48000, cutoffFreq: 48, cutoffFreq2: 52,
                              rippleDb: 0.5, stopbandDb: 50 },
                            { filterType: 3, filterResponse: 3, order: 4, sampleRate: 48000, cutoffFreq: 58, cutoffFreq2: 62,
                              rippleDb: 0.5, stopbandDb: 50 },
                            { filterType: 2, filterResponse: 1, order: 4, sampleRate: 8000, cutoffFreq: 300, cutoffFreq2: 3400,
                              rippleDb: 0.5 },
                            { filterType: 0, filterResponse: 3, order: 8, sampleRate: 48000, cutoffFreq: 20000,
                              rippleDb: 0.1, stopbandDb: 70 },
                            { filterType: 0, filterResponse: 0, order: 8, sampleRate: 96000, cutoffFreq: 40000 },
                            { filterType: 1, filterResponse: 0, order: 4, sampleRate: 48000, cutoffFreq: 10000 }
                        ]
                        onActivated: {
                            const spec = presetSpecs[currentIndex]
                            if (spec) filterEngine.applySpec(spec)
                            root.syncPendingWithEngine()
                        }
                    }
                }

                Item { width: 1; height: 2 }
                SectionHeader { text: "TYPE"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Topology"
                    StyledCombo {
                        width: parent.width
                        model: root.typeNames
                        currentIndex: root.hasPendingChanges ? root.pendingType : filterEngine.filterType
                        onActivated: {
                            root.pendingType = currentIndex
                            root.hasPendingChanges = true
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: "Structure"
                    SegmentedButton {
                        width: parent.width
                        implicitHeight: 28
                        model: ["IIR", "FIR"]
                        currentIndex: root.shownIsFir ? 1 : 0
                        onActivated: function(idx) { root.selectFilterClass(idx === 1) }
                    }
                }

                Hint {
                    text: root.shownIsFir
                          ? "Finite impulse response: exactly linear phase and always stable, at the cost of a high order"
                          : "Infinite impulse response: steep roll-off at low order, non-linear phase"
                }

                ParameterRow {
                    width: parent.width
                    visible: !root.shownIsFir
                    height: visible ? implicitHeight : 0
                    label: "Family"
                    StyledCombo {
                        width: parent.width
                        model: root.iirFamilyNames
                        currentIndex: root.shownIsFir ? root.lastIirResponse : root.shownResponse
                        onActivated: {
                            if (!root.hasPendingChanges) root.syncPendingWithEngine()
                            root.pendingResponse = currentIndex
                            root.lastIirResponse = currentIndex
                            root.pendingOrder = Math.min(root.pendingOrder, filterEngine.maxOrder(currentIndex))
                            root.hasPendingChanges = true
                        }
                    }
                }

                Hint {
                    visible: !root.shownIsFir
                    text: root.iirFamilyHints[root.shownResponse] || ""
                }

                ParameterRow {
                    width: parent.width
                    visible: root.shownIsFir
                    height: visible ? implicitHeight : 0
                    label: "Window"
                    StyledCombo {
                        width: parent.width
                        model: root.firWindowNames
                        currentIndex: root.shownFirWindow
                        onActivated: {
                            if (!root.hasPendingChanges) root.syncPendingWithEngine()
                            root.pendingFirWindow = currentIndex
                            // Gaussian needs sigma > 0; Tukey accepts 0..1
                            if (currentIndex === 11 && root.pendingFirWindowParam < 0.05)
                                root.pendingFirWindowParam = 0.4
                            root.hasPendingChanges = true
                        }
                    }
                }

                Hint {
                    visible: root.shownIsFir
                    text: root.firWindowHints[root.shownFirWindow] || ""
                }

                ParameterRow {
                    width: parent.width
                    visible: root.shownUsesParam
                    height: visible ? implicitHeight : 0
                    label: root.shownFirWindow === 11 ? "Sigma (\u03c3)" : "Alpha (\u03b1)"
                    StyledSlider {
                        width: parent.width
                        from: root.shownFirWindow === 11 ? 0.05 : 0.0
                        to: 1.0
                        value: root.hasPendingChanges ? root.pendingFirWindowParam : filterEngine.firWindowParam
                        stepSize: 0.01
                        valueDecimals: 2
                        onMoved: {
                            root.pendingFirWindowParam = Math.round(value * 100) / 100
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingFirWindowParam = Math.max(from, Math.min(1.0, Math.round(val * 100) / 100))
                            root.hasPendingChanges = true
                        }
                    }
                }

                Item { width: 1; height: 4 }
                SectionHeader { text: "PARAMETERS"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Order"
                    StyledSlider {
                        width: parent.width
                        from: 1
                        to: filterEngine.maxOrder(root.shownResponse)
                        value: root.shownOrder
                        stepSize: 1
                        valueDecimals: 0
                        onMoved: {
                            root.pendingOrder = Math.round(value)
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingOrder = Math.max(1, Math.min(to, Math.round(val)))
                            root.hasPendingChanges = true
                        }
                    }
                }

                Hint {
                    visible: root.shownIsFir
                    text: (root.shownEffectiveOrder + 1) + " taps · "
                          + (root.shownEffectiveOrder / 2) + " sample delay"
                          + (root.shownEffectiveOrder !== root.shownOrder
                             ? " · odd order raised to " + root.shownEffectiveOrder
                               + " (high-pass/band-stop need an odd tap count)"
                             : "")
                }

                ParameterRow {
                    width: parent.width
                    label: "Sample Rate"
                    StyledCombo {
                        width: parent.width
                        model: ["8000", "22050", "44100", "48000", "96000", "192000"]
                        currentIndex: {
                            const rates = [8000, 22050, 44100, 48000, 96000, 192000]
                            const curSR = root.hasPendingChanges ? root.pendingSampleRate : filterEngine.sampleRate
                            const i = rates.indexOf(Math.round(curSR))
                            return i >= 0 ? i : 3
                        }
                        onActivated: {
                            root.pendingSampleRate = parseFloat(model[currentIndex])
                            root.hasPendingChanges = true
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: root.isBand ? "Fc Low" : "Cutoff"
                    StyledSlider {
                        width: parent.width
                        from: 10
                        to: Math.max(20, (root.hasPendingChanges ? root.pendingSampleRate : filterEngine.sampleRate) / 2 - 1)
                        value: root.hasPendingChanges ? root.pendingCutoff : Math.min(filterEngine.cutoffFreq, filterEngine.sampleRate / 2 - 1)
                        stepSize: 1
                        valueSuffix: " Hz"
                        valueDecimals: 0
                        onMoved: {
                            root.pendingCutoff = Math.round(value)
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingCutoff = Math.round(val * 10) / 10
                            root.hasPendingChanges = true
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: root.isBand
                    height: visible ? implicitHeight : 0
                    opacity: visible ? 1 : 0
                    label: "Fc High"
                    StyledSlider {
                        width: parent.width
                        from: Math.min((root.hasPendingChanges ? root.pendingCutoff : filterEngine.cutoffFreq) + 10, (root.hasPendingChanges ? root.pendingSampleRate : filterEngine.sampleRate) / 2 - 2)
                        to: Math.max((root.hasPendingChanges ? root.pendingCutoff : filterEngine.cutoffFreq) + 20, (root.hasPendingChanges ? root.pendingSampleRate : filterEngine.sampleRate) / 2 - 1)
                        value: root.hasPendingChanges ? root.pendingCutoff2 : Math.max(filterEngine.cutoffFreq2, filterEngine.cutoffFreq + 10)
                        stepSize: 1
                        valueSuffix: " Hz"
                        valueDecimals: 0
                        onMoved: {
                            root.pendingCutoff2 = Math.round(value)
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingCutoff2 = Math.round(val * 10) / 10
                            root.hasPendingChanges = true
                        }
                    }
                }

                Hint {
                    text: root.isBand ? root.cutoffMeaning.replace("Cutoff =", "Each edge =") : root.cutoffMeaning
                }

                // Live Bandwidth & Q Readout Card for Band-pass / Band-stop
                Rectangle {
                    visible: root.isBand
                    width: parent.width
                    height: visible ? 32 : 0
                    radius: 5
                    color: theme.surfaceHigh
                    border.color: theme.borderColor
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 12
                        Text {
                            readonly property real fc1: root.hasPendingChanges ? root.pendingCutoff : filterEngine.cutoffFreq
                            readonly property real fc2: root.hasPendingChanges ? root.pendingCutoff2 : filterEngine.cutoffFreq2
                            text: "f₀: " + Math.round(Math.sqrt(fc1 * fc2)) + " Hz"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            color: theme.primaryText
                        }
                        Text {
                            readonly property real fc1: root.hasPendingChanges ? root.pendingCutoff : filterEngine.cutoffFreq
                            readonly property real fc2: root.hasPendingChanges ? root.pendingCutoff2 : filterEngine.cutoffFreq2
                            text: "BW: " + Math.round(fc2 - fc1) + " Hz"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            color: theme.secondaryText
                        }
                        Text {
                            readonly property real fc1: root.hasPendingChanges ? root.pendingCutoff : filterEngine.cutoffFreq
                            readonly property real fc2: root.hasPendingChanges ? root.pendingCutoff2 : filterEngine.cutoffFreq2
                            readonly property real bw: Math.max(1, fc2 - fc1)
                            readonly property real f0: Math.sqrt(fc1 * fc2)
                            text: "Q: " + (f0 / bw).toFixed(2)
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 11
                            font.bold: true
                            color: theme.accent
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: root.shownResponse === 1 || root.shownResponse === 3
                    height: visible ? implicitHeight : 0
                    label: "Ripple"
                    StyledSlider {
                        width: parent.width
                        from: 0.1
                        to: 5.0
                        value: root.hasPendingChanges ? root.pendingRipple : filterEngine.rippleDb
                        stepSize: 0.1
                        valueSuffix: " dB"
                        valueDecimals: 1
                        onMoved: {
                            root.pendingRipple = Math.round(value * 10) / 10
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingRipple = Math.round(val * 10) / 10
                            root.hasPendingChanges = true
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    visible: root.shownResponse === 2 || root.shownResponse === 3 || root.shownUsesAtten
                    height: visible ? implicitHeight : 0
                    label: root.shownIsFir ? (root.shownFirWindow === 15 ? "Sidelobe Atten." : "Kaiser Atten.") : "Stopband"
                    StyledSlider {
                        width: parent.width
                        from: 20
                        to: 120
                        value: root.hasPendingChanges ? root.pendingStopband : filterEngine.stopbandDb
                        stepSize: 1
                        valueSuffix: " dB"
                        valueDecimals: 0
                        onMoved: {
                            root.pendingStopband = Math.round(value)
                            root.hasPendingChanges = true
                        }
                        onManualValueEntered: function(val) {
                            root.pendingStopband = Math.round(val)
                            root.hasPendingChanges = true
                        }
                    }
                }

                Item { width: 1; height: 4 }
                SectionHeader { text: "PLOT DISPLAY & TOOLS"; width: parent.width }

                ParameterRow {
                    width: parent.width
                    label: "Line Width"
                    SegmentedButton {
                        width: parent.width
                        implicitHeight: 26
                        model: ["1.5px", "2.2px", "3.2px"]
                        currentIndex: {
                            if (Math.abs(freqPlot.plotLineWidth - 1.5) < 0.2) return 0
                            if (Math.abs(freqPlot.plotLineWidth - 2.2) < 0.2) return 1
                            return 2
                        }
                        onActivated: function(idx) {
                            const widths = [1.5, 2.2, 3.2]
                            freqPlot.plotLineWidth = widths[idx]
                            freqPlot.schedulePaint()
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: "Data Cursor (+)"
                    SegmentedButton {
                        width: parent.width
                        implicitHeight: 26
                        model: ["Off", "On"]
                        currentIndex: freqPlot.showCrosshair ? 1 : 0
                        onActivated: function(idx) {
                            freqPlot.showCrosshair = (idx === 1)
                            if (!freqPlot.showCrosshair) freqPlot.isHovering = false
                            freqPlot.schedulePaint()
                        }
                    }
                }

                ParameterRow {
                    width: parent.width
                    label: "Verifier"
                    Rectangle {
                        width: parent.width
                        height: 26
                        radius: 6
                        color: verBtnMouse.pressed ? "#0071E3" : (verBtnMouse.containsMouse ? theme.accent : (theme.isDark ? "#25272B" : "#E4E7EB"))
                        border.color: theme.borderColor
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 5
                            Codicon {
                                icon: "shield"
                                iconSize: 11
                                iconColor: verBtnMouse.containsMouse ? "#FFFFFF" : theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Verify Design"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: verBtnMouse.containsMouse ? "#FFFFFF" : theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: verBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: verifierModal.openVerification()
                        }
                    }
                }

                Item { width: 1; height: 2 }

                // ── Filter Inspector (flat, matches Configuration panel style) ──
                Item {
                    id: inspectorWrap
                    width: parent.width
                    height: inspToggleRow.height + (inspOpen ? inspCol.implicitHeight : 0)
                    clip: true
                    property bool inspOpen: false
                    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    // Toggle header — same styling as SectionHeader
                    Item {
                        id: inspToggleRow
                        width: parent.width
                        height: 32

                        Text {
                            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                            text: "Filter Inspector"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Codicon {
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            icon: inspectorWrap.inspOpen ? "chevron-up" : "chevron-down"
                            iconSize: 11
                            iconColor: theme.secondaryText
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: inspectorWrap.inspOpen = !inspectorWrap.inspOpen
                        }
                    }

                    // Body — flat rows, no background, no borders
                    Column {
                        id: inspCol
                        width: parent.width
                        anchors.top: inspToggleRow.bottom
                        spacing: 0

                        // Flat spec row — 32px, 12px text, overflow safe
                        component FlatRow: Item {
                            property string lbl: ""
                            property string val: ""
                            property color  valColor: theme.primaryText
                            width: parent.width
                            height: 32
                            Text {
                                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                text: lbl
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 12
                                color: theme.secondaryText
                                elide: Text.ElideRight
                                width: Math.min(implicitWidth, parent.width * 0.48)
                            }
                            Text {
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                                text: val
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: valColor
                                elide: Text.ElideLeft
                                width: Math.min(implicitWidth, parent.width * 0.52)
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // Sub-section label — same style as SectionHeader
                        component SubHeader: Text {
                            width: parent.width
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.letterSpacing: 0.8
                            color: theme.secondaryText
                            topPadding: 8
                            bottomPadding: 2
                        }

                        // ── Design ───────────────────────────────────────────
                        SubHeader { text: "DESIGN" }

                        FlatRow {
                            lbl: "Structure"
                            val: filterEngine.isFir ? "FIR · linear phase"
                                                    : "IIR · " + filterEngine.sectionCount + " biquad section"
                                                      + (filterEngine.sectionCount === 1 ? "" : "s")
                        }
                        FlatRow {
                            lbl: "Response"
                            val: filterEngine.responseName
                        }
                        FlatRow {
                            lbl: "Topology"
                            val: filterEngine.typeName
                        }
                        FlatRow {
                            lbl: "Order"
                            val: filterEngine.orderLabel.replace(" order", "")
                        }
                        FlatRow {
                            visible: filterEngine.isFir; height: visible ? 34 : 0
                            lbl: "Taps / Window"
                            val: filterEngine.tapCount + " \u00b7 " + filterEngine.windowLabel
                        }
                        FlatRow {
                            visible: filterEngine.isFir; height: visible ? 34 : 0
                            lbl: "Group Delay"
                            val: ((filterEngine.tapCount - 1) / 2).toFixed(1) + " smp (linear phase)"
                        }
                        FlatRow {
                            lbl: "Sample Rate"
                            val: filterEngine.sampleRate >= 1000
                                 ? (filterEngine.sampleRate / 1000).toFixed(1) + " kHz"
                                 : filterEngine.sampleRate + " Hz"
                        }
                        FlatRow {
                            lbl: filterEngine.filterType >= 2 ? "Fc Low" : "Cutoff (" + filterEngine.edgeDb.toFixed(1).replace("-", "\u2212") + " dB)"
                            val: filterEngine.cutoffFreq >= 1000
                                 ? (filterEngine.cutoffFreq / 1000).toFixed(3) + " kHz"
                                 : filterEngine.cutoffFreq.toFixed(1) + " Hz"
                        }
                        FlatRow {
                            visible: filterEngine.filterType >= 2; height: visible ? 34 : 0
                            lbl: "Fc High"
                            val: filterEngine.cutoffFreq2 >= 1000
                                 ? (filterEngine.cutoffFreq2 / 1000).toFixed(3) + " kHz"
                                 : filterEngine.cutoffFreq2.toFixed(1) + " Hz"
                        }
                        FlatRow {
                            visible: filterEngine.filterType >= 2; height: visible ? 34 : 0
                            lbl: "Centre (f\u2080)"
                            val: {
                                const f0 = Math.sqrt(filterEngine.cutoffFreq * filterEngine.cutoffFreq2)
                                return f0 >= 1000 ? (f0/1000).toFixed(3)+" kHz" : f0.toFixed(1)+" Hz"
                            }
                        }
                        FlatRow {
                            visible: filterEngine.filterType >= 2; height: visible ? 34 : 0
                            lbl: "Bandwidth"
                            val: {
                                const bw = filterEngine.cutoffFreq2 - filterEngine.cutoffFreq
                                return bw >= 1000 ? (bw/1000).toFixed(3)+" kHz" : Math.round(bw)+" Hz"
                            }
                        }
                        FlatRow {
                            visible: filterEngine.filterType >= 2; height: visible ? 34 : 0
                            lbl: "Q Factor"
                            val: {
                                const bw = Math.max(1, filterEngine.cutoffFreq2 - filterEngine.cutoffFreq)
                                const f0 = Math.sqrt(filterEngine.cutoffFreq * filterEngine.cutoffFreq2)
                                return (f0/bw).toFixed(3)
                            }
                        }
                        FlatRow {
                            visible: filterEngine.filterResponse === 1 || filterEngine.filterResponse === 3
                            height: visible ? 34 : 0
                            lbl: "Passband Ripple"
                            val: filterEngine.rippleDb.toFixed(2) + " dB"
                        }
                        FlatRow {
                            visible: filterEngine.filterResponse === 2 || filterEngine.filterResponse === 3 || filterEngine.windowUsesAtten
                            height: visible ? 34 : 0
                            lbl: filterEngine.isFir ? (filterEngine.firWindow === 15 ? "Sidelobe Atten." : "Kaiser Atten.") : "Stopband Atten."
                            val: filterEngine.stopbandDb.toFixed(1) + " dB"
                        }

                        // ── Analysis ─────────────────────────────────────────
                        SubHeader { text: "ANALYSIS" }

                        // Bound to properties (stabilityMargin = 1 - max |pole|) so they
                        // refresh on resultsChanged; invokable calls would not
                        FlatRow {
                            readonly property bool stable: !filterEngine.hasResults || filterEngine.stabilityMargin > 0
                            lbl: "System"
                            val: !filterEngine.hasResults ? "—" : (stable ? "Stable" : "Unstable")
                            valColor: stable ? theme.accent : theme.danger
                        }
                        FlatRow {
                            lbl: "Max Pole Radius"
                            val: filterEngine.hasResults ? (1 - filterEngine.stabilityMargin).toFixed(5) : "—"
                            valColor: !filterEngine.hasResults || filterEngine.stabilityMargin > 0 ? theme.primaryText : theme.danger
                        }
                        FlatRow {
                            lbl: "Stability Margin"
                            val: filterEngine.hasResults ? filterEngine.stabilityMargin.toFixed(4) : "\u2014"
                        }
                        FlatRow {
                            lbl: "Peak Gain"
                            val: filterEngine.hasResults ? filterEngine.peakGainDb.toFixed(3) + " dB" : "\u2014"
                        }
                        FlatRow {
                            lbl: "Peak Frequency"
                            val: {
                                if (!filterEngine.hasResults) return "\u2014"
                                const f = filterEngine.peakFreqHz
                                return f >= 1000 ? (f/1000).toFixed(3)+" kHz" : f.toFixed(1)+" Hz"
                            }
                        }
                        FlatRow {
                            lbl: "DC Gain"
                            val: filterEngine.hasResults ? filterEngine.steadyStateGain.toFixed(5) : "\u2014"
                        }

                        // ── Step Response ────────────────────────────────────
                        SubHeader { text: "STEP RESPONSE" }

                        FlatRow {
                            lbl: "Overshoot"
                            val: {
                                if (!filterEngine.hasResults) return "\u2014"
                                const m = filterEngine.stepMetrics
                                return m && m.overshootPercent !== undefined ? Number(m.overshootPercent).toFixed(2)+" %" : "\u2014"
                            }
                        }
                        FlatRow {
                            lbl: "Settling Time (2%)"
                            val: {
                                if (!filterEngine.hasResults) return "\u2014"
                                const m = filterEngine.stepMetrics
                                return m && m.settlingTimeSamples !== undefined ? m.settlingTimeSamples+" smp" : "\u2014"
                            }
                        }
                        FlatRow {
                            lbl: "Rise Time (10\u201390%)"
                            val: {
                                if (!filterEngine.hasResults) return "\u2014"
                                const m = filterEngine.stepMetrics
                                return m && m.riseTimeSamples !== undefined ? m.riseTimeSamples+" smp" : "\u2014"
                            }
                        }

                        Item { height: 8; width: 1 }
                    }
                }
            }
        }

        // Sticky Apply Button (Appears when manual configurations are pending)
        Rectangle {
            id: stickyApplyBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: root.hasPendingChanges ? 52 : 0
            color: theme.isDark ? "#1C1E22" : "#F4F5F8"
            border.color: theme.borderColor
            border.width: 1
            z: 30
            clip: true
            visible: height > 0
            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

            Item {
                anchors.centerIn: parent
                width: parent.width - 24
                height: 30

                // Discard: drop the pending edits and show the active design again
                Rectangle {
                    id: discardBtn
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                    width: Math.min(96, parent.width * 0.32)
                    radius: 7
                    color: discardMouse.containsMouse ? (theme.isDark ? "#2E3136" : "#E4E7EB") : "transparent"
                    border.color: theme.borderColor
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Discard"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }

                    MouseArea {
                        id: discardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.syncPendingWithEngine()
                    }
                }

                Rectangle {
                    anchors { left: discardBtn.right; leftMargin: 8; right: parent.right; top: parent.top; bottom: parent.bottom }
                    radius: 7
                    color: applyMouse.pressed ? "#0071E3" : (applyMouse.containsMouse ? theme.accent : theme.accent)
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Codicon {
                            icon: "check"
                            iconSize: 12
                            iconColor: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Apply Changes"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.applyPendingChanges()
                    }
                }
            }
        }

        Rectangle {
            anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
            width: 1
            color: theme.borderColor
            opacity: 0.55
            visible: !root.narrowLayout
        }
        Rectangle {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: 1
            color: theme.borderColor
            opacity: 0.55
            visible: root.narrowLayout
        }
    }

    // ── Plot area: unified workbench card ─────────────────────────────────────
    Rectangle {
        id: plotArea
        anchors {
            left: root.narrowLayout ? parent.left : configPanel.right
            top: root.narrowLayout ? configPanel.bottom : parent.top
            right: parent.right
            bottom: parent.bottom
            margins: root.pageMargin
        }
        color: theme.surface
        radius: 8
        border.color: theme.borderColor
        border.width: 1
        clip: true

        // Sticky VS Code Editor Tab Bar (seamlessly integrated into top of card)
        Rectangle {
            id: stickyTabBar
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: 38
            color: theme.isDark ? "#252526" : "#F3F3F3"
            z: 10

            // 1px horizontal separator line between tabs and plot
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: theme.borderColor
            }

            Row {
                id: tabRow
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: [
                        { label: "Magnitude",   unit: "dB",      icon: "graph" },
                        { label: "Phase",       unit: "°",       icon: "pulse" },
                        { label: "Group Delay", unit: "samples", icon: "history" }
                    ]
                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        readonly property bool active: freqPlot.displayMode === index
                        width: Math.max(90, tabContent.implicitWidth + 24)
                        height: stickyTabBar.height
                        color: active
                            ? (theme.isDark ? "#1E1E1E" : "#FFFFFF")
                            : (tabHov.hovered ? (theme.isDark ? "#2A2D2E" : "#E8E8E8") : "transparent")

                        // Active blue top indicator bar (VS Code tab style)
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 2
                            color: theme.accent
                            visible: parent.active
                        }

                        // Right vertical divider
                        Rectangle {
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            width: 1
                            color: theme.borderColor
                            visible: !parent.active
                        }

                        Row {
                            id: tabContent
                            anchors.centerIn: parent
                            spacing: 6

                            Codicon {
                                icon: modelData.icon
                                iconSize: 14
                                iconColor: parent.parent.active ? theme.accent : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.label
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                font.weight: parent.parent.active ? Font.DemiBold : Font.Normal
                                color: parent.parent.active ? theme.primaryText : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Unit pill badge
                            Rectangle {
                                width: unitText.implicitWidth + 8
                                height: 18
                                radius: 4
                                color: parent.parent.active
                                    ? (theme.isDark ? "#2D2D2D" : "#EAEAEA")
                                    : (theme.isDark ? "#1E1E1E" : "#DFDFDF")
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: unitText
                                    anchors.centerIn: parent
                                    text: modelData.unit
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                }
                            }
                        }

                        HoverHandler {
                            id: tabHov
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: freqPlot.displayMode = index
                        }
                    }
                }
            }

            // Real-time readout metric & window opener on the right of sticky bar
            Row {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }
                spacing: 10

                Text {
                    text: {
                        if (freqPlot.displayMode === 0)
                            return "Cutoff: " + Number(filterEngine.cutoffFreq).toLocaleString(Qt.locale(), "f", 0) + " Hz  ·  " + filterEngine.edgeDb.toFixed(1) + " dB"
                        else if (freqPlot.displayMode === 1)
                            return "Order: " + filterEngine.orderLabel.replace(" order", "") + "  ·  Unwrapped Phase"
                        else
                            return "Fs: " + Number(filterEngine.sampleRate).toLocaleString(Qt.locale(), "f", 0) + " Hz  ·  Exact τg"
                    }
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 12
                    color: theme.secondaryText
                    visible: stickyTabBar.width > 560
                    anchors.verticalCenter: parent.verticalCenter
                }

                // New Window Opener Icon Button
                Rectangle {
                    width: 26
                    height: 24
                    radius: 4
                    color: popTabMouse.containsMouse ? (theme.isDark ? "#32353A" : "#E2E5E9") : (theme.isDark ? "#2A2D2E" : "#EAEAEA")
                    border.color: theme.borderColor
                    border.width: 1
                    anchors.verticalCenter: parent.verticalCenter

                    Codicon {
                        anchors.centerIn: parent
                        icon: "link-external"
                        iconSize: 12
                        iconColor: popTabMouse.containsMouse ? theme.primaryText : theme.secondaryText
                    }

                    ToolTip.visible: popTabMouse.containsMouse
                    ToolTip.text: "Open Frequency Plot in Dedicated Window"
                    ToolTip.delay: 300

                    MouseArea {
                        id: popTabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const w = Window.window
                            if (w && typeof w.openStandalonePlot === "function") {
                                w.openStandalonePlot(0, { displayMode: freqPlot.displayMode })
                            }
                        }
                    }
                }
            }
        }


        // Plot canvas connected seamlessly below sticky tab bar
        FrequencyPlot {
            id: freqPlot
            anchors {
                left: parent.left
                right: parent.right
                top: stickyTabBar.bottom
                bottom: parent.bottom
            }
        }
    }

    DesignVerifierModal {
        id: verifierModal
        transientParent: root.Window.window
    }
}


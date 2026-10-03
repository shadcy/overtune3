import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root
    property var hostWindow: null
    title: "Overtune " + updateInstaller.currentVersion + " — DSP Window Function Studio"
    width: 1100
    height: 720
    minimumWidth: 880
    minimumHeight: 580
    visible: false
    flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint | Qt.CustomizeWindowHint
    transientParent: hostWindow
    color: theme.background
    palette.window: theme.background
    palette.windowText: theme.primaryText
    palette.base: theme.surface
    palette.text: theme.primaryText
    palette.button: theme.surfaceHigh
    palette.buttonText: theme.primaryText
    palette.highlight: theme.accent
    palette.highlightedText: "#FFFFFF"
    palette.mid: theme.borderColor
    palette.toolTipBase: theme.isDark ? "#222225" : "#FFFFFF"
    palette.toolTipText: theme.isDark ? "#FFFFFF" : "#1D1D1F"

    property string windowName: "Hann"
    property int sampleCount: 256
    property bool periodic: false
    property real kaiserBeta: 8.6
    property real tukeyAlpha: 0.5
    property real gaussianSigma: 0.4
    property int normalization: 0
    property var currentSamples: []
    property var previousSamples: []
    property var spectrumData: []
    property var metrics: ({})
    property real animationProgress: 1

    // View mode: 0 = Time Domain w[n], 1 = Frequency Spectrum |W(w)| (dB)
    property int viewMode: 0
    property bool showLatexSource: false
    property bool copiedNotice: false
    property real hoverX: -1
    property real hoverY: -1
    property bool isHovering: false

    Timer {
        id: copyTimer
        interval: 1800
        onTriggered: root.copiedNotice = false
    }

    readonly property var windowOptions: [
        "Rectangular", "Bartlett", "Hann", "Hamming", "Blackman",
        "Blackman-Harris", "Nuttall", "Flat Top", "Kaiser", "Tukey",
        "Gaussian", "Bohman", "Lanczos"
    ]
    readonly property bool narrow: width < 940

    function formulaKey(name) {
        switch (name) {
        case "Rectangular": return "rectangular"
        case "Bartlett": return "bartlett"
        case "Hann": return "hann"
        case "Hamming": return "hamming"
        case "Blackman": return "blackman"
        case "Blackman-Harris": return "blackman_harris"
        case "Nuttall": return "nuttall"
        case "Flat Top": return "flat_top"
        case "Kaiser": return "kaiser"
        case "Tukey": return "tukey"
        case "Gaussian": return "gaussian"
        case "Bohman": return "bohman"
        case "Lanczos": return "lanczos"
        default: return "hann"
        }
    }

    function latexCode(name) {
        switch (name) {
        case "Rectangular": return "w[n] = 1, \\quad 0 \\le n \\le M"
        case "Bartlett": return "w[n] = 1 - \\left| \\frac{n - \\frac{M}{2}}{\\frac{M}{2}} \\right|, \\quad 0 \\le n \\le M"
        case "Hann": return "w[n] = 0.5 - 0.5 \\cos\\left(\\frac{2\\pi n}{M}\\right) = \\sin^2\\left(\\frac{\\pi n}{M}\\right)"
        case "Hamming": return "w[n] = 0.54 - 0.46 \\cos\\left(\\frac{2\\pi n}{M}\\right)"
        case "Blackman": return "w[n] = 0.42 - 0.5 \\cos\\left(\\frac{2\\pi n}{M}\\right) + 0.08 \\cos\\left(\\frac{4\\pi n}{M}\\right)"
        case "Blackman-Harris": return "w[n] = 0.35875 - 0.48829 \\cos\\left(\\frac{2\\pi n}{M}\\right) + 0.14128 \\cos\\left(\\frac{4\\pi n}{M}\\right) - 0.01168 \\cos\\left(\\frac{6\\pi n}{M}\\right)"
        case "Nuttall": return "w[n] = 0.355768 - 0.487396 \\cos\\left(\\frac{2\\pi n}{M}\\right) + 0.144232 \\cos\\left(\\frac{4\\pi n}{M}\\right) - 0.012604 \\cos\\left(\\frac{6\\pi n}{M}\\right)"
        case "Flat Top": return "w[n] = a_0 - a_1 \\cos\\left(\\frac{2\\pi n}{M}\\right) + a_2 \\cos\\left(\\frac{4\\pi n}{M}\\right) - a_3 \\cos\\left(\\frac{6\\pi n}{M}\\right) + a_4 \\cos\\left(\\frac{8\\pi n}{M}\\right)"
        case "Kaiser": return "w[n] = \\frac{I_0\\left(\\beta \\sqrt{1 - \\left(\\frac{2n}{M} - 1\\right)^2}\\right)}{I_0(\\beta)}"
        case "Tukey": return "w[n] = \\begin{cases} \\frac{1}{2}\\left[1 + \\cos\\left(\\frac{\\pi}{\\alpha}\\left(\\frac{2n}{M} - \\alpha\\right)\\right)\\right], & 0 \\le n < \\frac{\\alpha M}{2} \\\\ 1, & \\frac{\\alpha M}{2} \\le n \\le M\\left(1 - \\frac{\\alpha}{2}\\right) \\\\ \\frac{1}{2}\\left[1 + \\cos\\left(\\frac{\\pi}{\\alpha}\\left(\\frac{2n}{M} - 2 + \\alpha\\right)\\right)\\right], & \\text{otherwise} \\end{cases}"
        case "Gaussian": return "w[n] = \\exp\\left( -\\frac{1}{2} \\left[ \\frac{n - \\frac{M}{2}}{\\sigma \\frac{M}{2}} \\right]^2 \\right)"
        case "Bohman": return "w[n] = (1 - |x|)\\cos(\\pi |x|) + \\frac{1}{\\pi}\\sin(\\pi |x|), \\quad x = \\frac{2n}{M} - 1"
        case "Lanczos": return "w[n] = \\operatorname{sinc}\\left(\\frac{2n}{M} - 1\\right) = \\frac{\\sin\\left(\\pi\\left(\\frac{2n}{M} - 1\\right)\\right)}{\\pi\\left(\\frac{2n}{M} - 1\\right)}"
        default: return ""
        }
    }

    function windowProfile(name) {
        switch (name) {
        case "Rectangular":
            return { sidelobe: "-13.3 dB", rolloff: "6 dB/oct", width: "4 pi / N", useCase: "Transient capture & uniform Dirichlet sinc kernel." }
        case "Bartlett":
            return { sidelobe: "-26.5 dB", rolloff: "12 dB/oct", width: "8 pi / N", useCase: "Linear taper with non-negative Bartlett triangular convolution." }
        case "Hann":
            return { sidelobe: "-31.5 dB", rolloff: "18 dB/oct", width: "8 pi / N", useCase: "General audio FFT, speech analysis & 50% overlap reconstruction." }
        case "Hamming":
            return { sidelobe: "-42.8 dB", rolloff: "6 dB/oct", width: "8 pi / N", useCase: "Cancels first sidelobe; narrowband communications & telecom." }
        case "Blackman":
            return { sidelobe: "-58.1 dB", rolloff: "18 dB/oct", width: "12 pi / N", useCase: "3-term cosine series for high dynamic range audio mastering." }
        case "Blackman-Harris":
            return { sidelobe: "-92.0 dB", rolloff: "6 dB/oct", width: "16 pi / N", useCase: "Ultra-low sidelobe leakage for harmonic distortion measurements." }
        case "Nuttall":
            return { sidelobe: "-93.3 dB", rolloff: "18 dB/oct", width: "16 pi / N", useCase: "Continuous 1st derivative cosine series with fast decay." }
        case "Flat Top":
            return { sidelobe: "-44.0 dB", rolloff: "6 dB/oct", width: "20 pi / N", useCase: "Calibration & precision amplitude metering (scalloping < 0.01 dB)." }
        case "Kaiser":
            return { sidelobe: "Variable", rolloff: "6 dB/oct", width: "Parametric", useCase: "Optimal DPSS approximation; beta trades mainlobe vs sidelobes." }
        case "Tukey":
            return { sidelobe: "Variable", rolloff: "18 dB/oct", width: "Variable", useCase: "Cosine-tapered boxcar; pulsed radar & astronomical imaging." }
        case "Gaussian":
            return { sidelobe: "Parametric", rolloff: "Exponential", width: "Variable", useCase: "Minimum time-bandwidth uncertainty product; Gabor analysis." }
        case "Bohman":
            return { sidelobe: "-46.0 dB", rolloff: "24 dB/oct", width: "11.2 pi / N", useCase: "Fast 24 dB/oct decay; acoustic impulse and resonance testing." }
        case "Lanczos":
            return { sidelobe: "-26.4 dB", rolloff: "12 dB/oct", width: "6.4 pi / N", useCase: "Central sinc lobe for anti-aliased reconstruction and resampling." }
        default:
            return { sidelobe: "-", rolloff: "-", width: "-", useCase: "-" }
        }
    }

    function computeSpectrum(coeffs) {
        if (!coeffs || !coeffs.length) return []
        const N = coeffs.length
        const K = 256
        const raw = []
        let maxMag = 0
        const step = Math.max(1, Math.floor(N / 512))

        for (let k = 0; k < K; ++k) {
            const omega = (Math.PI * k) / (K - 1)
            let re = 0
            let im = 0
            for (let n = 0; n < N; n += step) {
                const phase = omega * n
                const val = coeffs[n]
                re += val * Math.cos(phase)
                im -= val * Math.sin(phase)
            }
            const mag = Math.sqrt(re * re + im * im)
            if (mag > maxMag) maxMag = mag
            raw.push(mag)
        }

        const norm = maxMag > 1e-12 ? maxMag : 1
        const result = []
        for (let k = 0; k < K; ++k) {
            const db = 20 * Math.log10(Math.max(1e-6, raw[k] / norm))
            result.push(Math.max(-120, db))
        }
        return result
    }

    function openStudio() {
        if (!visible) {
            if (transientParent) {
                x = Math.max(0, transientParent.x + (transientParent.width - width) / 2)
                y = Math.max(0, transientParent.y + (transientParent.height - height) / 2)
            } else if (Screen.desktopAvailableWidth && Screen.desktopAvailableHeight) {
                x = Math.max(0, (Screen.desktopAvailableWidth - width) / 2)
                y = Math.max(0, (Screen.desktopAvailableHeight - height) / 2)
            }
            visible = true
        }
        raise()
        requestActivate()
        refresh(false)
    }

    Shortcut { sequence: "Escape"; onActivated: root.close() }

    function refresh(animate) {
        if (typeof filterEngine === "undefined" || !filterEngine) return
        const next = filterEngine.computeWindow(windowName, sampleCount, periodic,
                                                kaiserBeta, tukeyAlpha, gaussianSigma,
                                                normalization)
        if (!next) return
        metrics = next
        if (next.error && next.error.length) {
            currentSamples = []
            spectrumData = []
            coefficientCanvas.requestPaint()
            return
        }

        const rawCoeffs = next.coefficients || []
        const newSamples = []
        for (let i = 0; i < rawCoeffs.length; ++i) {
            newSamples.push(Number(rawCoeffs[i]))
        }

        if (currentSamples && currentSamples.length > 0) {
            previousSamples = currentSamples.slice(0)
        } else {
            previousSamples = newSamples.slice(0)
        }
        currentSamples = newSamples
        spectrumData = computeSpectrum(newSamples)

        if (animate && theme.animationsEnabled && previousSamples.length > 0) {
            animationProgress = 0
            coefficientAnimation.restart()
        } else {
            animationProgress = 1
        }
        coefficientCanvas.requestPaint()
    }

    onVisibleChanged: if (visible) refresh(false)

    NumberAnimation {
        id: coefficientAnimation
        target: root
        property: "animationProgress"
        from: 0
        to: 1
        duration: theme.animNormal || 200
        easing.type: Easing.OutCubic
        onRunningChanged: coefficientCanvas.requestPaint()
    }

    onAnimationProgressChanged: coefficientCanvas.requestPaint()
    onViewModeChanged: coefficientCanvas.requestPaint()
    onWindowNameChanged: refresh(true)
    onSampleCountChanged: refresh(true)
    onPeriodicChanged: refresh(true)
    onKaiserBetaChanged: refresh(true)
    onTukeyAlphaChanged: refresh(true)
    onGaussianSigmaChanged: refresh(true)
    onNormalizationChanged: refresh(true)

    Component.onCompleted: {
        refresh(false)
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Clean Header Bar (No redundant close button, no cluttery subtitles) ─────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: theme.surface

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: theme.borderColor
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    Codicon {
                        icon: "graph"
                        iconSize: 18
                        iconColor: theme.accent
                    }

                    Text {
                        text: "DSP Window Function Studio"
                        color: theme.primaryText
                        font.family: theme.headlineFont
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        height: 20
                        width: vBadge.implicitWidth + 12
                        radius: 10
                        color: theme.accentMuted
                        Text {
                            id: vBadge
                            anchors.centerIn: parent
                            text: "v" + updateInstaller.currentVersion
                            color: theme.accent
                            font.family: theme.bodyFont
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Display mode badge
                    Text {
                        text: root.sampleCount + " samples  •  " + (root.periodic ? "Periodic" : "Symmetric")
                        color: theme.secondaryText
                        font.family: theme.bodyFont
                        font.pixelSize: 11
                    }
                }
            }

            // ── Main Body Split: Controls & Visualization ─────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 16
                spacing: 16

                // ── Left Panel: Controls & LaTeX Compiled Formula ─────────────
                Rectangle {
                    Layout.preferredWidth: root.narrow ? 270 : 310
                    Layout.minimumWidth: 260
                    Layout.maximumWidth: 340
                    Layout.fillHeight: true
                    color: theme.surface
                    radius: 8
                    border.color: theme.borderColor
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 14
                        clip: true
                        contentWidth: availableWidth

                        ColumnLayout {
                            width: parent.width
                            spacing: 12

                            Text {
                                text: "CONFIGURATION"
                                color: theme.secondaryText
                                font.family: theme.headlineFont
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 1.0
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: "Window Function"; color: theme.secondaryText; font.pixelSize: 11 }
                                StyledCombo {
                                    id: windowCombo
                                    Layout.fillWidth: true
                                    model: root.windowOptions
                                    currentIndex: Math.max(0, root.windowOptions.indexOf(root.windowName))
                                    onActivated: {
                                        if (currentIndex >= 0 && currentIndex < root.windowOptions.length)
                                            root.windowName = root.windowOptions[currentIndex]
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: "Length (samples)"; color: theme.secondaryText; font.pixelSize: 11 }
                                SpinBox {
                                    id: sampleCountBox
                                    Layout.fillWidth: true
                                    from: 3
                                    to: 65536
                                    stepSize: 1
                                    editable: true
                                    value: root.sampleCount
                                    onValueModified: root.sampleCount = value

                                    contentItem: TextInput {
                                        text: sampleCountBox.displayText
                                        font: sampleCountBox.font
                                        color: theme.primaryText
                                        selectionColor: theme.accent
                                        selectedTextColor: "#FFFFFF"
                                        horizontalAlignment: TextInput.AlignLeft
                                        verticalAlignment: TextInput.AlignVCenter
                                        leftPadding: 10
                                        rightPadding: 48
                                        readOnly: !sampleCountBox.editable
                                        validator: sampleCountBox.validator
                                        inputMethodHints: Qt.ImhDigitsOnly
                                    }

                                    background: Rectangle {
                                        radius: 6
                                        color: theme.background
                                        border.color: sampleCountBox.activeFocus ? theme.accent : theme.borderColor
                                        border.width: sampleCountBox.activeFocus ? 1.5 : 1
                                    }

                                    up.indicator: Rectangle {
                                        x: parent.width - width
                                        width: 24
                                        height: parent.height / 2
                                        color: sampleCountBox.up.pressed ? theme.surfaceHigh : "transparent"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "+"
                                            color: theme.secondaryText
                                            font.pixelSize: 12
                                        }
                                    }

                                    down.indicator: Rectangle {
                                        x: parent.width - width
                                        y: parent.height / 2
                                        width: 24
                                        height: parent.height / 2
                                        color: sampleCountBox.down.pressed ? theme.surfaceHigh : "transparent"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "-"
                                            color: theme.secondaryText
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: "Sampling"; color: theme.secondaryText; font.pixelSize: 11 }
                                StyledCombo {
                                    Layout.fillWidth: true
                                    model: ["Symmetric (M = N - 1)", "Periodic (M = N)"]
                                    currentIndex: root.periodic ? 1 : 0
                                    onActivated: root.periodic = (currentIndex === 1)
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text { text: "Normalization"; color: theme.secondaryText; font.pixelSize: 11 }
                                StyledCombo {
                                    Layout.fillWidth: true
                                    model: ["None", "Peak = 1", "Coherent gain = 1", "Energy = N"]
                                    currentIndex: root.normalization
                                    onActivated: root.normalization = currentIndex
                                }
                            }

                            // Dynamic parameter sliders
                            ParameterRow {
                                Layout.fillWidth: true
                                visible: root.windowName === "Kaiser"
                                label: "Kaiser beta"
                                StyledSlider {
                                    width: parent.width
                                    from: 0; to: 20; stepSize: 0.1; value: root.kaiserBeta
                                    valueDecimals: 1
                                    onMoved: root.kaiserBeta = value
                                    onManualValueEntered: function(v) { root.kaiserBeta = v }
                                }
                            }
                            ParameterRow {
                                Layout.fillWidth: true
                                visible: root.windowName === "Tukey"
                                label: "Tukey alpha"
                                StyledSlider {
                                    width: parent.width
                                    from: 0; to: 1; stepSize: 0.01; value: root.tukeyAlpha
                                    valueDecimals: 2
                                    onMoved: root.tukeyAlpha = value
                                    onManualValueEntered: function(v) { root.tukeyAlpha = v }
                                }
                            }
                            ParameterRow {
                                Layout.fillWidth: true
                                visible: root.windowName === "Gaussian"
                                label: "Gaussian sigma"
                                StyledSlider {
                                    width: parent.width
                                    from: 0.01; to: 10; stepSize: 0.01; value: root.gaussianSigma
                                    valueDecimals: 2
                                    onMoved: root.gaussianSigma = value
                                    onManualValueEntered: function(v) { root.gaussianSigma = v }
                                }
                            }

                            // ── LaTeX Compiled Formula Card ───────────────────────────
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                implicitHeight: formulaBoxCol.implicitHeight + 20
                                radius: 7
                                color: theme.background
                                border.color: theme.borderColor
                                border.width: 1

                                ColumnLayout {
                                    id: formulaBoxCol
                                    anchors {
                                        top: parent.top; left: parent.left; right: parent.right
                                        margins: 10
                                    }
                                    spacing: 8

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "FORMULA"
                                            color: theme.accent
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            font.letterSpacing: 0.8
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Copy LaTeX Button
                                        Rectangle {
                                            width: copyBtnLbl.implicitWidth + 12
                                            height: 20
                                            radius: 4
                                            color: copyMouse.containsMouse ? theme.surfaceHigh : "transparent"
                                            border.color: theme.borderColor
                                            border.width: 1

                                            Text {
                                                id: copyBtnLbl
                                                anchors.centerIn: parent
                                                text: root.copiedNotice ? "Copied!" : "Copy LaTeX"
                                                color: root.copiedNotice ? theme.accent : theme.secondaryText
                                                font.pixelSize: 10
                                                font.weight: Font.Medium
                                            }

                                            MouseArea {
                                                id: copyMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (typeof filterEngine !== "undefined" && typeof filterEngine.copyText === "function") {
                                                        filterEngine.copyText(root.latexCode(root.windowName))
                                                        root.copiedNotice = true
                                                        copyTimer.restart()
                                                    }
                                                }
                                            }
                                        }

                                        // Toggle LaTeX code / Rendered Image
                                        Rectangle {
                                            width: toggleBtnLbl.implicitWidth + 12
                                            height: 20
                                            radius: 4
                                            color: togMouse.containsMouse ? theme.surfaceHigh : "transparent"
                                            border.color: theme.borderColor
                                            border.width: 1

                                            Text {
                                                id: toggleBtnLbl
                                                anchors.centerIn: parent
                                                text: root.showLatexSource ? "Rendered" : "TeX"
                                                color: theme.accent
                                                font.pixelSize: 10
                                                font.weight: Font.Medium
                                            }

                                            MouseArea {
                                                id: togMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.showLatexSource = !root.showLatexSource
                                            }
                                        }
                                    }

                                    // Compiled LaTeX Formula Image (Dark & Light theme aware)
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: root.showLatexSource ? Math.max(52, latexBox.implicitHeight + 16) : (root.windowName === "Tukey" ? 72 : 52)
                                        radius: 6
                                        color: theme.surface
                                        border.color: theme.borderColor
                                        border.width: 1
                                        clip: true

                                        Image {
                                            id: latexImg
                                            visible: !root.showLatexSource && status === Image.Ready
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            fillMode: Image.PreserveAspectFit
                                            horizontalAlignment: Image.AlignLeft
                                            verticalAlignment: Image.AlignVCenter
                                            mipmap: true
                                            smooth: true
                                            source: "qrc:/FilterDesigner/math/win_" + root.formulaKey(root.windowName) + "_" + (theme.isDark ? "dark" : "light") + ".png"
                                        }

                                        // Raw LaTeX Source Display when toggled
                                        Rectangle {
                                            id: latexBox
                                            visible: root.showLatexSource || latexImg.status !== Image.Ready
                                            anchors.fill: parent
                                            anchors.margins: 4
                                            color: "transparent"

                                            Text {
                                                anchors.fill: parent
                                                anchors.margins: 6
                                                text: root.latexCode(root.windowName)
                                                font.family: "Cascadia Code, Consolas, Courier New, monospace"
                                                font.pixelSize: 10
                                                color: theme.primaryText
                                                wrapMode: Text.WordWrap
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // ── Right Panel: Interactive Dual-Domain Plot & Metric Cards ───
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 14

                    // Main Plot Card (Consistent with DesignPage freqPlot container)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: theme.surface
                        radius: 8
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        // Plot Mode Header Bar (Coefficients vs Frequency Spectrum)
                        Rectangle {
                            id: plotToolbar
                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }
                            height: 42
                            color: "transparent"

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: theme.borderColor
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                spacing: 10

                                // View mode segmented toggle
                                Row {
                                    spacing: 4

                                    Rectangle {
                                        width: btnCoeff.implicitWidth + 16
                                        height: 26
                                        radius: 5
                                        color: root.viewMode === 0 ? theme.accent : (hovCoeff.containsMouse ? theme.surfaceHigh : "transparent")
                                        border.color: root.viewMode === 0 ? theme.accent : theme.borderColor
                                        border.width: 1

                                        Text {
                                            id: btnCoeff
                                            anchors.centerIn: parent
                                            text: "Coefficients  w[n]"
                                            color: root.viewMode === 0 ? "#FFFFFF" : theme.primaryText
                                            font.family: "Stack Sans Headline"
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                        }

                                        MouseArea {
                                            id: hovCoeff
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.viewMode = 0
                                        }
                                    }

                                    Rectangle {
                                        width: btnSpec.implicitWidth + 16
                                        height: 26
                                        radius: 5
                                        color: root.viewMode === 1 ? theme.accent : (hovSpec.containsMouse ? theme.surfaceHigh : "transparent")
                                        border.color: root.viewMode === 1 ? theme.accent : theme.borderColor
                                        border.width: 1

                                        Text {
                                            id: btnSpec
                                            anchors.centerIn: parent
                                            text: "Spectrum  |W(ω)| (dB)"
                                            color: root.viewMode === 1 ? "#FFFFFF" : theme.primaryText
                                            font.family: "Stack Sans Headline"
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                        }

                                        MouseArea {
                                            id: hovSpec
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.viewMode = 1
                                        }
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                // Interactive Hover Readout Badge
                                Rectangle {
                                    visible: root.isHovering && root.hoverX >= 0
                                    height: 22
                                    width: readoutText.implicitWidth + 16
                                    radius: 4
                                    color: theme.background
                                    border.color: theme.accent
                                    border.width: 1

                                    Text {
                                        id: readoutText
                                        anchors.centerIn: parent
                                        color: theme.accent
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        text: {
                                            if (!root.currentSamples.length) return ""
                                            if (root.viewMode === 0) {
                                                const idx = Math.min(root.currentSamples.length - 1, Math.max(0, Math.round(root.hoverX * (root.currentSamples.length - 1))))
                                                const val = Number(root.currentSamples[idx] || 0).toFixed(4)
                                                return "n = " + idx + " : w[n] = " + val
                                            } else {
                                                const freqNorm = Number(root.hoverX).toFixed(3)
                                                if (root.spectrumData && root.spectrumData.length) {
                                                    const sIdx = Math.min(root.spectrumData.length - 1, Math.max(0, Math.round(root.hoverX * (root.spectrumData.length - 1))))
                                                    const db = Number(root.spectrumData[sIdx] || 0).toFixed(1)
                                                    return "ω = " + freqNorm + "π : " + db + " dB"
                                                }
                                                return "ω = " + freqNorm + "π"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Canvas {
                            id: coefficientCanvas
                            anchors {
                                top: plotToolbar.bottom
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                margins: 10
                            }

                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.reset()

                                const left = 50
                                const right = width - 20
                                const top = 16
                                const bottom = height - 28
                                const plotWidth = Math.max(1, right - left)
                                const plotHeight = Math.max(1, bottom - top)

                                if (root.viewMode === 0) {
                                    // ── Mode 0: Time Domain Coefficients w[n] ─────────────────
                                    const yMin = -0.3
                                    const yMax = 1.25
                                    const yRange = yMax - yMin

                                    function toY(val) {
                                        const clamped = Math.max(yMin, Math.min(yMax, val))
                                        return bottom - ((clamped - yMin) / yRange) * plotHeight
                                    }

                                    // Horizontal grid levels
                                    const gridLevels = [
                                        { val: 1.0, label: "1.00", dashed: true },
                                        { val: 0.5, label: "0.50", dashed: true },
                                        { val: 0.0, label: "0.00", dashed: false },
                                        { val: -0.25, label: "-0.25", dashed: true }
                                    ]

                                    ctx.lineWidth = 1
                                    ctx.font = "10px sans-serif"
                                    for (let g = 0; g < gridLevels.length; ++g) {
                                        const lvl = gridLevels[g]
                                        const py = toY(lvl.val)
                                        ctx.strokeStyle = lvl.val === 0.0 ? theme.borderColor : (theme.isDark ? "#2A2D33" : "#E4E7EB")
                                        ctx.globalAlpha = lvl.val === 0.0 ? 0.9 : 0.45
                                        ctx.beginPath()
                                        ctx.moveTo(left, py)
                                        ctx.lineTo(right, py)
                                        ctx.stroke()

                                        ctx.fillStyle = theme.secondaryText
                                        ctx.globalAlpha = 0.85
                                        ctx.fillText(lvl.label, 8, py + 3)
                                    }

                                    // Y and X axis bounding lines
                                    ctx.strokeStyle = theme.borderColor
                                    ctx.globalAlpha = 0.8
                                    ctx.beginPath()
                                    ctx.moveTo(left, top); ctx.lineTo(left, bottom); ctx.lineTo(right, bottom)
                                    ctx.stroke()

                                    // X axis sample labels
                                    ctx.fillStyle = theme.secondaryText
                                    ctx.globalAlpha = 0.85
                                    ctx.fillText("0", left - 2, height - 8)
                                    const halfIdx = Math.floor(Math.max(1, root.currentSamples.length - 1) / 2)
                                    ctx.fillText(String(halfIdx), left + plotWidth * 0.5 - 8, height - 8)
                                    ctx.fillText(String(Math.max(0, root.currentSamples.length - 1)), right - 24, height - 8)

                                    const count = root.currentSamples.length
                                    if (!count) return
                                    const shown = Math.min(count, 2048)

                                    // Gradient fill
                                    const fillGrad = ctx.createLinearGradient(0, top, 0, bottom)
                                    fillGrad.addColorStop(0, theme.accent + "40")
                                    fillGrad.addColorStop(1, theme.accent + "04")

                                    ctx.fillStyle = fillGrad
                                    ctx.globalAlpha = 1
                                    ctx.beginPath()
                                    const zeroY = toY(0.0)
                                    ctx.moveTo(left, zeroY)

                                    for (let j = 0; j < shown; ++j) {
                                        const index = shown === 1 ? 0 : Math.round(j * (count - 1) / (shown - 1))
                                        const a = Number(root.previousSamples[index] ?? root.currentSamples[index])
                                        const b = Number(root.currentSamples[index])
                                        const value = a + (b - a) * root.animationProgress
                                        const x = left + plotWidth * j / Math.max(1, shown - 1)
                                        const y = toY(value)
                                        ctx.lineTo(x, y)
                                    }
                                    ctx.lineTo(right, zeroY)
                                    ctx.closePath()
                                    ctx.fill()

                                    // Stroke line
                                    ctx.strokeStyle = theme.accent
                                    ctx.lineWidth = 2.5
                                    ctx.globalAlpha = 1
                                    ctx.beginPath()
                                    for (let j = 0; j < shown; ++j) {
                                        const index = shown === 1 ? 0 : Math.round(j * (count - 1) / (shown - 1))
                                        const a = Number(root.previousSamples[index] ?? root.currentSamples[index])
                                        const b = Number(root.currentSamples[index])
                                        const value = a + (b - a) * root.animationProgress
                                        const x = left + plotWidth * j / Math.max(1, shown - 1)
                                        const y = toY(value)
                                        if (j === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                                    }
                                    ctx.stroke()

                                } else {
                                    // ── Mode 1: Frequency Spectrum |W(w)| in dB [0 to -120 dB] ──
                                    const dbMin = -120.0
                                    const dbMax = 0.0
                                    const dbRange = dbMax - dbMin

                                    function toDbY(db) {
                                        const clamped = Math.max(dbMin, Math.min(dbMax, db))
                                        return top + ((dbMax - clamped) / dbRange) * plotHeight
                                    }

                                    const dbLevels = [0, -20, -40, -60, -80, -100, -120]
                                    ctx.lineWidth = 1
                                    ctx.font = "10px sans-serif"
                                    for (let g = 0; g < dbLevels.length; ++g) {
                                        const dbVal = dbLevels[g]
                                        const py = toDbY(dbVal)
                                        ctx.strokeStyle = dbVal === 0 ? theme.borderColor : (theme.isDark ? "#2A2D33" : "#E4E7EB")
                                        ctx.globalAlpha = dbVal === 0 ? 0.9 : 0.45
                                        ctx.beginPath()
                                        ctx.moveTo(left, py)
                                        ctx.lineTo(right, py)
                                        ctx.stroke()

                                        ctx.fillStyle = theme.secondaryText
                                        ctx.globalAlpha = 0.85
                                        ctx.fillText(dbVal + " dB", 6, py + 3)
                                    }

                                    // Y and X axis bounding lines
                                    ctx.strokeStyle = theme.borderColor
                                    ctx.globalAlpha = 0.8
                                    ctx.beginPath()
                                    ctx.moveTo(left, top); ctx.lineTo(left, bottom); ctx.lineTo(right, bottom)
                                    ctx.stroke()

                                    // X axis frequency labels (0 to pi rad/sample)
                                    ctx.fillStyle = theme.secondaryText
                                    ctx.globalAlpha = 0.85
                                    ctx.fillText("0", left - 2, height - 8)
                                    ctx.fillText("0.25 π", left + plotWidth * 0.25 - 12, height - 8)
                                    ctx.fillText("0.50 π", left + plotWidth * 0.50 - 12, height - 8)
                                    ctx.fillText("0.75 π", left + plotWidth * 0.75 - 12, height - 8)
                                    ctx.fillText("π rad", right - 22, height - 8)

                                    const sLen = root.spectrumData.length
                                    if (!sLen) return

                                    // Fill under frequency spectrum curve
                                    const fillGrad = ctx.createLinearGradient(0, top, 0, bottom)
                                    fillGrad.addColorStop(0, theme.accent + "35")
                                    fillGrad.addColorStop(1, theme.accent + "04")

                                    ctx.fillStyle = fillGrad
                                    ctx.globalAlpha = 1
                                    ctx.beginPath()
                                    ctx.moveTo(left, bottom)

                                    for (let j = 0; j < sLen; ++j) {
                                        const db = Number(root.spectrumData[j])
                                        const x = left + plotWidth * j / Math.max(1, sLen - 1)
                                        const y = toDbY(db)
                                        ctx.lineTo(x, y)
                                    }
                                    ctx.lineTo(right, bottom)
                                    ctx.closePath()
                                    ctx.fill()

                                    // Stroke spectrum curve
                                    ctx.strokeStyle = theme.accent
                                    ctx.lineWidth = 2
                                    ctx.globalAlpha = 1
                                    ctx.beginPath()
                                    for (let j = 0; j < sLen; ++j) {
                                        const db = Number(root.spectrumData[j])
                                        const x = left + plotWidth * j / Math.max(1, sLen - 1)
                                        const y = toDbY(db)
                                        if (j === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                                    }
                                    ctx.stroke()
                                }

                                // Draw hover vertical line and indicator
                                if (root.isHovering && root.hoverX >= 0) {
                                    const hx = left + plotWidth * root.hoverX
                                    ctx.strokeStyle = theme.accent
                                    ctx.lineWidth = 1
                                    ctx.globalAlpha = 0.6
                                    ctx.beginPath()
                                    ctx.moveTo(hx, top)
                                    ctx.lineTo(hx, bottom)
                                    ctx.stroke()
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onPositionChanged: function(mouse) {
                                    const left = 50
                                    const right = width - 20
                                    const plotWidth = Math.max(1, right - left)
                                    if (mouse.x >= left && mouse.x <= right) {
                                        root.hoverX = (mouse.x - left) / plotWidth
                                        root.hoverY = mouse.y
                                        root.isHovering = true
                                    } else {
                                        root.isHovering = false
                                    }
                                    coefficientCanvas.requestPaint()
                                }
                                onExited: {
                                    root.isHovering = false
                                    coefficientCanvas.requestPaint()
                                }
                            }
                        }
                    }

                    // ── Clean Metric Cards (No cluttery subtitles) ─────────────
                    GridLayout {
                        Layout.fillWidth: true
                        columns: root.narrow ? 2 : 3
                        rowSpacing: 10
                        columnSpacing: 12

                        Repeater {
                            model: [
                                { label: "Coherent Gain (DC)", value: Number(root.metrics.coherentGain || 0).toFixed(6) },
                                { label: "ENBW (bins)", value: Number(root.metrics.enbwBins || 0).toFixed(4) },
                                { label: "RMS Amplitude", value: Number(root.metrics.rms || 0).toFixed(6) },
                                { label: "Energy", value: Number(root.metrics.energy || 0).toFixed(6) },
                                { label: "Coefficient Sum", value: Number(root.metrics.sum || 0).toFixed(6) },
                                { label: "Sample Length", value: String(root.sampleCount) }
                            ]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 52
                                color: theme.surface
                                radius: 6
                                border.color: theme.borderColor
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 3

                                    Text {
                                        text: modelData.label
                                        color: theme.secondaryText
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                    }

                                    Text {
                                        text: modelData.value
                                        color: theme.primaryText
                                        font.family: theme.headlineFont
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }

                    // Error text banner if any
                    Text {
                        Layout.fillWidth: true
                        visible: !!(root.metrics.error && root.metrics.error.length)
                        text: root.metrics.error || ""
                        color: theme.danger
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}


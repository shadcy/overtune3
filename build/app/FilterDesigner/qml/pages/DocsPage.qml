import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"
import "../theme"

// DocsPage.qml — VS Code documentation style (clean typography, no blocks/cards, hypertext routes)
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property bool isNarrow: width < 760
    property int selectedTopic: 0

    function go(pageIndex) {
        const w = Window.window
        if (w && typeof w.navigateTo === "function")
            w.navigateTo(pageIndex)
    }

    readonly property var topics: [
        { id: "overview",   title: "Overview & Quickstart",     tag: "Getting Started" },
        { id: "topologies", title: "Filter Topologies",         tag: "Design" },
        { id: "responses",  title: "Approximation Types",       tag: "Design" },
        { id: "maths",      title: "DSP Mathematics & SOS",     tag: "Theory" },
        { id: "simulation", title: "Signal Simulation & Audio", tag: "Simulation" },
        { id: "export",     title: "Code Export & Integration", tag: "Code" }
    ]

    Row {
        anchors.fill: parent

        // ─── Left Sidebar (VS Code Documentation Navigation) ───────────────
        Rectangle {
            id: tocSidebar
            width: root.isNarrow ? 180 : 230
            height: parent.height
            color: theme.isDark ? "#181818" : "#F3F3F3"
            border.color: theme.borderColor
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text {
                    text: "DOCUMENTATION"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                    color: theme.secondaryText
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.borderColor
                }

                ListView {
                    id: tocList
                    width: parent.width
                    height: parent.height - 40
                    clip: true
                    model: root.topics
                    spacing: 2

                    delegate: Rectangle {
                        width: tocList.width
                        height: 32
                        radius: 4
                        color: {
                            if (root.selectedTopic === index)
                                return theme.isDark ? "#2A2D2E" : "#E4E4E4"
                            if (itemHov.hovered)
                                return theme.isDark ? "#1F1F1F" : "#EBEBEB"
                            return "transparent"
                        }

                        Rectangle {
                            width: 3
                            height: 18
                            radius: 1.5
                            color: theme.accent
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.selectedTopic === index
                        }

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 12
                                right: parent.right
                                rightMargin: 8
                                verticalCenter: parent.verticalCenter
                            }
                            text: modelData.title
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            font.weight: root.selectedTopic === index ? Font.Medium : Font.Normal
                            color: root.selectedTopic === index ? theme.primaryText : theme.secondaryText
                            elide: Text.ElideRight
                        }

                        HoverHandler { id: itemHov }
                        TapHandler {
                            onTapped: {
                                root.selectedTopic = index
                                docFlick.contentY = 0
                            }
                        }
                    }
                }
            }
        }

        // ─── Main Content Area (Clean VS Code Article) ─────────────────────
        Flickable {
            id: docFlick
            width: parent.width - tocSidebar.width
            height: parent.height
            clip: true
            contentWidth: width
            contentHeight: articleCol.implicitHeight + 48
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: docFlick.contentHeight > docFlick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: articleCol
                width: Math.min(docFlick.width - (root.isNarrow ? 32 : 64), 780)
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 24
                bottomPadding: 32
                spacing: 20

                // Breadcrumb path
                Row {
                    spacing: 6
                    Text {
                        text: "Docs"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.accent
                    }
                    Text {
                        text: "/"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.secondaryText
                    }
                    Text {
                        text: "Overtune 3"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.secondaryText
                    }
                    Text {
                        text: "/"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.secondaryText
                    }
                    Text {
                        text: root.topics[root.selectedTopic].title
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        color: theme.primaryText
                    }
                }

                // Document Title
                Text {
                    width: parent.width
                    text: root.topics[root.selectedTopic].title
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 26
                    font.weight: Font.Bold
                    color: theme.primaryText
                }

                // Underline separator
                Rectangle {
                    width: parent.width
                    height: 1
                    color: theme.borderColor
                }

                // ─── TOPIC 0: Overview & Quickstart ────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 0

                    Text {
                        width: parent.width
                        text: "Overtune 3 is an interactive digital signal processing workstation for designing, analyzing, simulating, and exporting recursive infinite impulse response (IIR) digital filters."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Key Workflow Routes"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        topPadding: 8
                    }

                    // Hypertext route 1
                    Row {
                        spacing: 8
                        Text { text: "•"; color: theme.secondaryText; font.pixelSize: 14 }
                        Text {
                            text: "Filter Designer Studio"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovR1.hovered
                            color: theme.accent
                            HoverHandler { id: hovR1; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(0) }
                        }
                        Text {
                            text: "— configure topology (Lowpass, Highpass, Bandpass, Bandstop), response approximation, and interactive cutoff frequency."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            color: theme.secondaryText
                            width: articleCol.width - 240
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Hypertext route 2
                    Row {
                        spacing: 8
                        Text { text: "•"; color: theme.secondaryText; font.pixelSize: 14 }
                        Text {
                            text: "Analysis & Visualisation"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovR2.hovered
                            color: theme.accent
                            HoverHandler { id: hovR2; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(1) }
                        }
                        Text {
                            text: "— inspect high-resolution magnitude dB, unwrapped continuous phase, exact group delay, and z-plane pole-zero plots."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            color: theme.secondaryText
                            width: articleCol.width - 240
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Hypertext route 3
                    Row {
                        spacing: 8
                        Text { text: "•"; color: theme.secondaryText; font.pixelSize: 14 }
                        Text {
                            text: "Signal & Audio Simulation"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovR3.hovered
                            color: theme.accent
                            HoverHandler { id: hovR3; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(2) }
                        }
                        Text {
                            text: "— generate test signals (sine, chirp, noise) or load 16/24-bit WAV audio files to test filter filtering in real time."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            color: theme.secondaryText
                            width: articleCol.width - 240
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Hypertext route 4
                    Row {
                        spacing: 8
                        Text { text: "•"; color: theme.secondaryText; font.pixelSize: 14 }
                        Text {
                            text: "Production Code Exporter"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovR4.hovered
                            color: theme.accent
                            HoverHandler { id: hovR4; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(3) }
                        }
                        Text {
                            text: "— export Second-Order Section (SOS) biquad coefficients for C, C++20, Python SciPy, and JSON configurations."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            color: theme.secondaryText
                            width: articleCol.width - 240
                            wrapMode: Text.WordWrap
                        }
                    }

                    Text {
                        text: "Architecture Highlights"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        topPadding: 16
                    }

                    Text {
                        width: parent.width
                        text: "All digital filter designs in Overtune 3 are synthesized strictly in Second-Order Sections (biquads). Factoring higher-order polynomials into coupled biquad stages mitigates finite word-length coefficient quantization errors and prevents overflow instability typical of direct-form realization."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }
                }

                // ─── TOPIC 1: Filter Topologies ────────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 1

                    Text {
                        width: parent.width
                        text: "Overtune 3 provides 4 primary standard filter frequency transformation topologies via frequency pre-warping and bilinear mapping."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "1. Lowpass Filter (LPF)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Passes spectral energy below the primary cutoff frequency Fc while attenuating higher frequencies. Transmission zeros from analog infinity map directly to z = -1 (Nyquist)."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "2. Highpass Filter (HPF)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Attenuates low frequencies and DC offset while passing signals above Fc. Under inverted analog frequency mapping, prototype zeros at infinity map exactly to z = +1 (DC), ensuring zero DC transmission."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "3. Bandpass Filter (BPF)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Passes frequencies strictly within the passband between Fc1 and Fc2. Each prototype pole maps to a complex conjugate pair, doubling the filter order. Zeros are placed in equal numbers at z = +1 and z = -1."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "4. Bandstop Filter (BSF / Notch)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Eliminates unwanted spectral components between Fc1 and Fc2 (such as 50/60 Hz power-line hum or acoustic resonance peaks). Zeros are synthesized directly on the unit circle at the digital center frequency."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Row {
                        spacing: 6
                        topPadding: 8
                        Text {
                            text: "→ Adjust filter topologies in the Designer"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovTop.hovered
                            color: theme.accent
                            HoverHandler { id: hovTop; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(0) }
                        }
                    }
                }

                // ─── TOPIC 2: Approximation Types ──────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 2

                    Text {
                        width: parent.width
                        text: "Five classical mathematical approximations are supported, each optimized for specific trade-offs between magnitude ripple, phase linearity, and transition steepness."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Butterworth (Maximally Flat)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Features a completely monotonic response with no ripple in either the passband or stopband. The magnitude response satisfies |H(jΩ)|² = 1 / (1 + (Ω/Ωc)^(2N)). It is the standard choice when smooth response without coloration is desired."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Chebyshev Type I (Passband Equiripple)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Minimizes the maximum error over the passband by introducing controlled ripple (Rp dB). For the same order, Chebyshev I provides a much sharper transition band than Butterworth."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Chebyshev Type II (Inverse Chebyshev)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Provides a maximally flat passband and equiripple stopband. Stopband attenuation (Rs dB) is guaranteed. Contains finite zeros on the imaginary axis that map to the unit circle."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Elliptic / Cauer"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Features equiripple behavior in both the passband and stopband using Jacobi elliptic functions. Yields the absolute steepest possible cutoff for a given order, at the cost of non-linear phase distortion."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Bessel / Thomson (Linear Phase)"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Maximizes the flatness of the group delay in the passband based on reverse Bessel polynomials. Preserves waveshapes and transients with zero ringing or overshoot, making it ideal for audio mastering and pulse communications."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Row {
                        spacing: 6
                        topPadding: 8
                        Text {
                            text: "→ View frequency and phase response curves in Analysis"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovAn.hovered
                            color: theme.accent
                            HoverHandler { id: hovAn; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(1) }
                        }
                    }
                }

                // ─── TOPIC 3: DSP Mathematics & SOS ────────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 3

                    Text {
                        width: parent.width
                        text: "Overtune 3 synthesizes all filters with rigorous numerical mathematics. Below is the theoretical formulation used across the computation pipeline."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "1. Tangent Pre-Warping"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Because the bilinear transform non-linearly compresses the infinite analog frequency axis into the digital range [-π, π], analog prototype cutoff frequencies are pre-warped:\n\n    Ω = 2 * Fs * tan(π * Fc / Fs)\n\nThis ensures exact matching of critical frequencies in the discrete domain."
                        font.family: "Monospace"
                        font.pixelSize: 13
                        color: theme.isDark ? "#D4D4D4" : "#24292E"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.4
                    }

                    Text {
                        text: "2. Second-Order Section (SOS) Decomposition"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "The overall transfer function H(z) is factored into a cascade of biquads:\n\n    H(z) = G * ∏ [ (b0_k + b1_k*z⁻¹ + b2_k*z⁻²) / (1 + a1_k*z⁻¹ + a2_k*z⁻²) ]\n\nComplex poles and zeros are grouped into exact conjugate pairs to guarantee real coefficients."
                        font.family: "Monospace"
                        font.pixelSize: 13
                        color: theme.isDark ? "#D4D4D4" : "#24292E"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.4
                    }

                    Text {
                        text: "3. Exact Analytical Group Delay"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Rather than noisy numerical difference quotients, Overtune 3 evaluates the exact analytical phase derivative across every biquad stage:\n\n    τ_g(ω) = Re{ (b1*z⁻¹ + 2*b2*z⁻²) / B(z) } - Re{ (a1*z⁻¹ + 2*a2*z⁻²) / A(z) }\n\nThis yields mathematically exact delay values with zero numerical noise."
                        font.family: "Monospace"
                        font.pixelSize: 13
                        color: theme.isDark ? "#D4D4D4" : "#24292E"
                        wrapMode: Text.WordWrap
                        lineHeight: 1.4
                    }
                }

                // ─── TOPIC 4: Signal Simulation & Audio ─────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 4

                    Text {
                        width: parent.width
                        text: "The simulation environment allows instant auditioning and time-domain waveform inspection of how your designed filter alters synthetic test signals and real audio files."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Supported Test Signals"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "• Sine Wave: single frequency tone for inspecting gain and phase shift.\n• Frequency Chirp: linear frequency sweep from 20 Hz to 20 kHz to visualize cutoff rolloff.\n• Square Wave: rich harmonic series to observe high-frequency attenuation and transient edge response.\n• White Noise: uniform power across all frequencies for full spectrum filtering."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }

                    Text {
                        text: "Audio File Import"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }
                    Text {
                        width: parent.width
                        text: "Load uncompressed 16-bit or 24-bit PCM WAV audio files. The engine processes the signal through the biquad cascade in real time and provides instant A/B playback comparison."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Row {
                        spacing: 6
                        topPadding: 8
                        Text {
                            text: "→ Open Signal Simulation Studio"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovSim.hovered
                            color: theme.accent
                            HoverHandler { id: hovSim; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(2) }
                        }
                    }
                }

                // ─── TOPIC 5: Code Export & Integration ─────────────────────
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.selectedTopic === 5

                    Text {
                        width: parent.width
                        text: "Export production-ready biquad code with zero dynamic memory allocation, suitable for microcontrollers, embedded DSPs, audio plugins, and scientific workflows."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.45
                    }

                    Text {
                        text: "Available Export Targets"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                    }

                    Text {
                        width: parent.width
                        text: "• Embedded C: Static arrays and Direct Form II Transposed processing function with static state buffers. Clean MISRA-C compliant code.\n• Modern C++20: Templated biquad cascade struct with constexpr section counts and zero overhead.\n• Python (SciPy): Standard 6-column SOS coefficient matrix formatted for scipy.signal.sosfilt.\n• JSON: Structured section coefficients, poles, zeros, and specification metadata for automated build toolchains."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 14
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        lineHeight: 1.5
                    }

                    Row {
                        spacing: 6
                        topPadding: 8
                        Text {
                            text: "→ Open Code Exporter"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.underline: hovExp.hovered
                            color: theme.accent
                            HoverHandler { id: hovExp; cursorShape: Qt.PointingHandCursor }
                            TapHandler { onTapped: root.go(3) }
                        }
                    }
                }
            }
        }
    }
}

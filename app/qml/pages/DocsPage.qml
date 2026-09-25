import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

// DocsPage.qml — Clean modular docs: Get Started, Theory & Math with LaTeX, Step-by-Step Tutorials, and Contributors & Wiki
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property bool isNarrow: width < 720
    readonly property int pageMargin: isNarrow ? 18 : 36

    property int activeTab: 0 // 0=Get Started, 1=Theory & Math, 2=Tutorials, 3=Contributors & Wiki

    function go(pageIndex) {
        const w = Window.window
        if (w && typeof w.navigateTo === "function")
            w.navigateTo(pageIndex)
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // ─── Sticky Sub-Navigation Bar ─────────────────────────────────────────
        Rectangle {
            id: navBar
            width: parent.width
            height: 42
            color: theme.isDark ? "#1E1E1E" : "#F3F3F3"
            border.color: theme.accent
            border.width: 0
            z: 10

            // Bottom border in primary blue
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: theme.isDark ? "#282828" : "#E0E0E0"
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: root.pageMargin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: [
                        { label: "Get Started",         icon: "book" },
                        { label: "Theory & Math",       icon: "graph" },
                        { label: "Tutorials & Guides",   icon: "mortar-board" },
                        { label: "Contributors & Wiki",  icon: "organization" }
                    ]
                    delegate: Rectangle {
                        required property int index
                        required property var modelData

                        readonly property bool active: root.activeTab === index
                        width: Math.max(80, tabTextRow.implicitWidth + 24)
                        height: navBar.height
                        color: active
                            ? (theme.isDark ? "#252526" : "#FFFFFF")
                            : (nhov.hovered ? (theme.isDark ? "#2A2D2E" : "#E8E8E8") : "transparent")

                        // Active blue bottom indicator
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 2
                            color: theme.accent
                            visible: parent.active
                        }

                        Row {
                            id: tabTextRow
                            anchors.centerIn: parent
                            spacing: 8

                            Codicon {
                                icon: modelData.icon
                                iconSize: 14
                                iconColor: parent.parent.active ? theme.accent : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.label
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 12
                                font.weight: parent.parent.active ? Font.DemiBold : Font.Normal
                                color: parent.parent.active ? theme.primaryText : theme.secondaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        HoverHandler {
                            id: nhov
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: {
                                root.activeTab = index
                                docFlick.contentY = 0
                            }
                        }
                    }
                }
            }
        }

        // ─── Scrollable Content Area ───────────────────────────────────────────
        Flickable {
            id: docFlick
            width: parent.width
            height: parent.height - navBar.height
            clip: true
            contentWidth: width
            contentHeight: contentCol.implicitHeight + 64
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar {
                policy: docFlick.contentHeight > docFlick.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: contentCol
                width: Math.min(docFlick.width - root.pageMargin * 2, 880)
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 24
                bottomPadding: 32
                spacing: 28

                // ═════════════════════════════════════════════════════════════════
                // TAB 0: GET STARTED
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 24
                    visible: root.activeTab === 0

                    // Headline
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Overtune 3"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: root.isNarrow ? 24 : 32
                            font.weight: Font.Bold
                            color: theme.primaryText
                        }

                        Text {
                            text: "Digital Filter Designer & DSP Simulation Workstation"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            color: theme.secondaryText
                        }
                    }

                    // Clean Theory Summary without boxes
                    Column {
                        width: parent.width
                        spacing: 12

                        Row {
                            spacing: 8
                            Codicon {
                                icon: "info"
                                iconSize: 16
                                iconColor: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Theory & Principles at a Glance"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Digital Infinite Impulse Response (IIR) filters compute discrete output samples using feedforward linear combinations of present and past inputs together with feedback from past outputs. In Overtune 3, transfer functions are mapped into the digital domain via the bilinear transformation with frequency pre-warping and decomposed into cascaded Second-Order Sections (SOS biquads) for numerical stability:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq1"
                            title: "Direct Form II Difference Equation"
                            equationNumber: "(1)"
                            renderedHtml: "<i>y</i>[<i>n</i>] = &sum;<sub><i>k</i>=0</sub><sup><i>M</i></sup> <i>b</i><sub><i>k</i></sub><i>x</i>[<i>n</i>&minus;<i>k</i>] &minus; &sum;<sub><i>k</i>=1</sub><sup><i>N</i></sup> <i>a</i><sub><i>k</i></sub><i>y</i>[<i>n</i>&minus;<i>k</i>]"
                            latexSource: "y[n] = \\sum_{k=0}^{M} b_k x[n-k] - \\sum_{k=1}^{N} a_k y[n-k]"
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq2"
                            title: "Second-Order Section (SOS) Cascade Transfer Function"
                            equationNumber: "(2)"
                            renderedHtml: "<i>H</i>(<i>z</i>) = <i>g</i> &middot; &prod;<sub><i>k</i>=1</sub><sup><i>K</i></sup> <i>H</i><sub><i>k</i></sub>(<i>z</i>)"
                            latexSource: "H(z) = g \\cdot \\prod_{k=1}^{K} \\frac{b_{0,k} + b_{1,k} z^{-1} + b_{2,k} z^{-2}}{1 + a_{1,k} z^{-1} + a_{2,k} z^{-2}}"
                        }
                    }

                    // Two-Column: Start + Shortcuts
                    GridLayout {
                        width: parent.width
                        columns: root.isNarrow ? 1 : 2
                        rowSpacing: 24
                        columnSpacing: 40

                        // Start Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Start"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                bottomPadding: 4
                            }

                            Repeater {
                                model: [
                                    { text: "New Filter Design...",         icon: "new-file",     page: 0 },
                                    { text: "Inspect Frequency & Poles...", icon: "graph",        page: 1 },
                                    { text: "Run Signal Simulation...",     icon: "play",         page: 2 },
                                    { text: "Export Production Code...",    icon: "export",       page: 3 },
                                    { text: "Configure Settings...",        icon: "settings-gear", page: 5 },
                                    { text: "Deep Theory & Mathematics...", icon: "book",         tab: 1 },
                                    { text: "Step-by-Step Tutorials...",    icon: "mortar-board", tab: 2 },
                                    { text: "Contributors & Wiki...",       icon: "organization", tab: 3 },
                                    { text: "GitHub Repository (shadcy/overtune3)...", icon: "link-external", url: "https://github.com/shadcy/overtune3" },
                                    { text: "Report an Issue / Suggestion...", icon: "link-external", url: "https://github.com/shadcy/overtune3/issues" }
                                ]
                                delegate: Row {
                                    spacing: 10
                                    height: 24

                                    Codicon {
                                        icon: modelData.icon
                                        iconSize: 15
                                        iconColor: startHov.hovered ? theme.accent : theme.secondaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.text
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: startHov.hovered
                                        color: startHov.hovered ? theme.accent : theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter

                                        HoverHandler {
                                            id: startHov
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                        TapHandler {
                                            onTapped: {
                                                if (modelData.hasOwnProperty("url")) {
                                                    Qt.openUrlExternally(modelData.url)
                                                } else if (modelData.hasOwnProperty("tab")) {
                                                    root.activeTab = modelData.tab
                                                    docFlick.contentY = 0
                                                } else {
                                                    root.go(modelData.page)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Shortcuts Section
                        Column {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Shortcuts"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                bottomPadding: 4
                            }

                            Repeater {
                                model: [
                                    { keys: ["Ctrl", "Tab"],    label: "Next Workspace Tab" },
                                    { keys: ["Ctrl", "1..6"],   label: "Direct Tab Switch (1..6)" },
                                    { keys: ["Ctrl", "S"],      label: "Save / Export Code to File" },
                                    { keys: ["Ctrl", "R"],      label: "Reset Filter to Defaults" },
                                    { keys: ["Ctrl", "K"],      label: "Clear Simulation Buffers" },
                                    { keys: ["Alt", "1..3"],    label: "Switch Plot Sub-Tabs" }
                                ]
                                delegate: Row {
                                    spacing: 12
                                    height: 24

                                    Row {
                                        spacing: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        Repeater {
                                            model: modelData.keys
                                            delegate: Text {
                                                text: modelData + (index < parent.children.length - 1 ? " +" : "")
                                                font.family: "Monospace"
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: theme.accent
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.label
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        color: theme.secondaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Row {
                                spacing: 6
                                topPadding: 8

                                Codicon {
                                    icon: "link-external"
                                    iconSize: 12
                                    iconColor: theme.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Visit GitHub: shadcy/overtune3"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: ghHov.hovered
                                    color: theme.accent
                                    anchors.verticalCenter: parent.verticalCenter

                                    HoverHandler {
                                        id: ghHov
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                    TapHandler {
                                        onTapped: Qt.openUrlExternally("https://github.com/shadcy/overtune3")
                                    }
                                }
                            }
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 1: THEORY & MATHEMATICS
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 24
                    visible: root.activeTab === 1

                    Text {
                        text: "DSP Theory & Mathematical Foundations"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: theme.primaryText
                    }

                    // Section 1: Analog Prototype
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "1. Analog Prototype Syntheses"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "Digital IIR filters are synthesized by calculating the complex poles and zeros of classical normalized analog prototypes (Ωc = 1 rad/s). The poles for an n-th order Butterworth prototype lie on the left-half unit circle:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq3"
                            title: "Butterworth Prototype S-Plane Poles"
                            equationNumber: "(3)"
                            renderedHtml: "<i>s</i><sub><i>k</i></sub> = exp(<i>j</i> &middot; &pi;(2<i>k</i> + <i>n</i> &minus; 1) / 2<i>n</i>), &nbsp;&nbsp; <i>k</i> = 1, 2, ..., <i>n</i>"
                            latexSource: "s_k = \\exp\\left( j \\frac{\\pi(2k + n - 1)}{2n} \\right), \\quad k = 1, \\dots, n"
                        }

                        Text {
                            width: parent.width
                            text: "• Butterworth: Maximally flat passband response with monotonic attenuation.\n• Chebyshev Type I: Equiripple passband with steep roll-off, minimizing peak error.\n• Chebyshev Type II: Maximally flat passband with equiripple stopband zeros.\n• Elliptic (Cauer): Jacobian elliptic rational functions for sharpest transition band.\n• Bessel (Thomson): Maximally flat group delay, linear phase, and zero ringing."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }
                    }

                    // Section 2: Bilinear Transform & Pre-Warping
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "2. Bilinear Transform with Tangent Pre-Warping"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "The bilinear transform maps the continuous-time complex s-plane into the discrete-time z-plane via trapezoidal integration. Because the digital frequency interval [0, π] non-linearly compresses the infinite analog frequency axis [0, ∞), all critical cutoff frequencies are pre-warped:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq4"
                            title: "Bilinear Mapping & Frequency Pre-Warping"
                            equationNumber: "(4)"
                            renderedHtml: "<i>s</i> = (2/<i>T</i>) &middot; (1 &minus; <i>z</i><sup>&minus;1</sup>) / (1 + <i>z</i><sup>&minus;1</sup>) &nbsp;&hArr;&nbsp; &Omega; = 2<i>f</i><sub><i>s</i></sub> tan(&pi;<i>f</i><sub><i>c</i></sub> / <i>f</i><sub><i>s</i></sub>)"
                            latexSource: "s = \\frac{2}{T} \\frac{1 - z^{-1}}{1 + z^{-1}} \\iff \\Omega = 2 f_s \\tan\\left( \\frac{\\pi f_c}{f_s} \\right)"
                        }
                    }

                    // Section 3: SOS Conjugate Pairing
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "3. Second-Order Section (SOS) Conjugate Pairing"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "Direct realization of high-order transfer functions suffers from severe numerical coefficient sensitivity. Overtune 3 groups complex roots into strict conjugate pairs (p, p*) to ensure purely real biquad coefficients, factoring high-order filters into cascades of 2nd-order sections:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq5"
                            title: "Second-Order Section Biquad Polynomial Factorization"
                            equationNumber: "(5)"
                            renderedHtml: "(1 &minus; <i>p</i><sub><i>k</i></sub><i>z</i><sup>&minus;1</sup>)(1 &minus; <i>p</i><sub><i>k</i></sub><sup>*</sup><i>z</i><sup>&minus;1</sup>) = 1 &minus; 2 Re(<i>p</i><sub><i>k</i></sub>)<i>z</i><sup>&minus;1</sup> + |<i>p</i><sub><i>k</i></sub>|<sup>2</sup><i>z</i><sup>&minus;2</sup>"
                            latexSource: "(1 - p_k z^{-1})(1 - p_k^* z^{-1}) = 1 - 2\\,\\text{Re}(p_k)z^{-1} + |p_k|^2 z^{-2}"
                        }
                    }

                    // Section 4: Group Delay & Unit Circle Stability
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "4. Group Delay & Stability Criteria"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "Group delay represents the time delay of amplitude envelopes across frequencies. A causal digital IIR filter is Bounded-Input Bounded-Output (BIBO) stable if and only if all system poles lie strictly inside the complex unit circle |z| < 1:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq6"
                            title: "Analytical Group Delay Computation"
                            equationNumber: "(6)"
                            renderedHtml: "&tau;<sub><i>g</i></sub>(&omega;) = &minus; d&theta;(&omega;) / d&omega;"
                            latexSource: "\\tau_g(\\omega) = -\\frac{d\\theta(\\omega)}{d\\omega} = \\sum_{k=1}^{K} \\left[ \\frac{P_{a,k}(\\omega)}{|A_k(e^{j\\omega})|^2} - \\frac{P_{b,k}(\\omega)}{|B_k(e^{j\\omega})|^2} \\right]"
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 2: STEP-BY-STEP TUTORIALS & WORKFLOW GUIDES
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 24
                    visible: root.activeTab === 2

                    Text {
                        text: "Step-by-Step DSP Workflow Tutorials"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: theme.primaryText
                    }

                    Text {
                        text: "Interactive guides for designing, analyzing, simulating, and deploying digital filters across audio, instrumentation, and embedded firmware applications."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                    }

                    // ── Student Tutorial Studio & Creator ────────────────────────────
                    TutorialStudio {
                        width: parent.width
                    }

                    // ── Built-in Guides ──────────────────────────────────────────────
                    Text {
                        text: "Guided Filter Workflows"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        topPadding: 12
                    }

                    // Workflow 1: Studio Audio Lowpass
                    Column {
                        width: parent.width
                        spacing: 8

                        Row {
                            spacing: 8
                            Rectangle {
                                width: 3
                                height: 16
                                color: theme.accent
                                radius: 1.5
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Workflow 1: Studio Audio Lowpass & Noise Reduction"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Remove high-frequency tape hiss above 12,000 Hz from 48 kHz recordings without phase smearing.\n• Topology: Lowpass (LPF) | Approximation: Butterworth | Order: 4 (2 Biquads)\n• Corner Frequency: Fc = 12,000 Hz | Sampling Rate: Fs = 48,000 Hz\n• Expected Result: Flat 0 dB passband with clean 24 dB/octave attenuation slope above 12 kHz."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }

                        Row {
                            spacing: 6
                            Codicon { icon: "link-external"; iconSize: 12; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: "Configure in Filter Designer Studio ↗"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.go(0) }
                            }
                        }
                    }

                    // Workflow 2: Mains Hum 50/60 Hz Notch
                    Column {
                        width: parent.width
                        spacing: 8

                        Row {
                            spacing: 8
                            Rectangle {
                                width: 3
                                height: 16
                                color: theme.accent
                                radius: 1.5
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Workflow 2: 50 Hz / 60 Hz Ground Loop Notch Rejection"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Eliminate 50 Hz or 60 Hz AC electrical hum from sensor telemetry while preserving nearby audio fundamentals.\n• Topology: Bandstop (Notch) | Approximation: Elliptic | Order: 4\n• Bandwidth: Fc1 = 49 Hz, Fc2 = 51 Hz (2 Hz notch) | Stopband Attenuation: 60 dB\n• Expected Result: Transmission zeros placed on the unit circle (|z| = 1.0) provide mathematical -inf dB rejection."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }

                        Row {
                            spacing: 6
                            Codicon { icon: "link-external"; iconSize: 12; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: "Open Frequency Analysis Suite ↗"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.go(1) }
                            }
                        }
                    }

                    // Workflow 3: Telephony Bandpass
                    Column {
                        width: parent.width
                        spacing: 8

                        Row {
                            spacing: 8
                            Rectangle {
                                width: 3
                                height: 16
                                color: theme.accent
                                radius: 1.5
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Workflow 3: Voice Telephony Bandpass (ITU-T G.712 Standards)"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Design a 300 Hz to 3,400 Hz voice bandpass filter to reject DC drift and out-of-band acoustic noise.\n• Topology: Bandpass (BPF) | Approximation: Chebyshev Type I | Order: 6 | Ripple: 0.5 dB\n• Lower Cutoff: Fc1 = 300 Hz | Upper Cutoff: Fc2 = 3,400 Hz | Fs = 16,000 Hz\n• Expected Result: Minimal delay distortion across the speech formant range (500 - 2,500 Hz)."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }

                        Row {
                            spacing: 6
                            Codicon { icon: "link-external"; iconSize: 12; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                            Text {
                                text: "Export Production Code ↗"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.go(3) }
                            }
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 3: CONTRIBUTORS & WIKI REFERENCES (Clean, No Tables/Boxes)
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 28
                    visible: root.activeTab === 3

                    // Title
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Contributors & DSP Knowledge Base"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: theme.primaryText
                        }

                        Text {
                            text: "Open-source community links, contribution guidelines, and direct Wikipedia reference articles for digital filter approximations."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                        }
                    }

                    // ── 1. Contributors & Community Section ──────────────────────────
                    Column {
                        width: parent.width
                        spacing: 14

                        Row {
                            spacing: 8
                            Codicon {
                                icon: "organization"
                                iconSize: 16
                                iconColor: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Contributors & Community"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Overtune 3 is an open-source project hosted on GitHub. We welcome contributions from digital signal processing researchers, audio engineers, embedded developers, and UI designers."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        // GitHub Links Row
                        Row {
                            spacing: 16

                            // GitHub Repository Button
                            Rectangle {
                                width: repoBtnText.implicitWidth + 24
                                height: 32
                                radius: 4
                                color: "transparent"
                                border.color: theme.accent
                                border.width: 1

                                Row {
                                    id: repoBtnText
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Codicon {
                                        icon: "github"
                                        iconSize: 14
                                        iconColor: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "GitHub Repository"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                HoverHandler { id: rHov; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: Qt.openUrlExternally("https://github.com/shadcy/overtune3") }
                            }

                            // GitHub Issues Button
                            Rectangle {
                                width: issueBtnText.implicitWidth + 24
                                height: 32
                                radius: 4
                                color: "transparent"
                                border.color: theme.accent
                                border.width: 1

                                Row {
                                    id: issueBtnText
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Codicon {
                                        icon: "issue-opened"
                                        iconSize: 14
                                        iconColor: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Report Issues & Feedback"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                HoverHandler { id: iHov; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: Qt.openUrlExternally("https://github.com/shadcy/overtune3/issues") }
                            }
                        }

                        // Contribution guidelines list
                        Column {
                            width: parent.width
                            spacing: 8
                            topPadding: 4

                            Text {
                                text: "How You Can Contribute:"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

                            Text {
                                width: parent.width
                                text: "• DSP Core Algorithms: Implement new analog prototypes (Legendre, Papoulis Optimum L, Gaussian) or FIR Parks-McClellan routines in pure C++20.\n• Numerical Optimization: Improve bilinear transformation precision and high-order SOS stability.\n• Audio Simulation: Enhance multi-channel WAV playback and spectral analysis visualizations.\n• Interactive Tutorials: Author student guides and practical presets via Tutorial Studio."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            Text {
                                width: parent.width
                                text: "Maintainer: shadcy (https://github.com/shadcy)\nRepository: https://github.com/shadcy/overtune3\nBug Reports & Feature Requests: https://github.com/shadcy/overtune3/issues"
                                font.family: "Monospace"
                                font.pixelSize: 11
                                color: theme.accent
                                wrapMode: Text.WordWrap
                                topPadding: 4
                            }
                        }
                    }

                    // ── 2. Wikipedia Articles & Reference Knowledge Base ─────────────
                    Column {
                        width: parent.width
                        spacing: 16

                        Row {
                            spacing: 8
                            Codicon {
                                icon: "book"
                                iconSize: 16
                                iconColor: theme.accent
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Wikipedia Reference Articles"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Text {
                            width: parent.width
                            text: "Click any article below to read in-depth derivations, frequency response proofs, and historical documentation on Wikipedia:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                        }

                        Repeater {
                            model: [
                                {
                                    title: "Butterworth Filter",
                                    desc: "Maximally flat magnitude filter with zero passband ripple and monotonic attenuation (6N dB/octave).",
                                    url: "https://en.wikipedia.org/wiki/Butterworth_filter"
                                },
                                {
                                    title: "Chebyshev Filter (Type I & II)",
                                    desc: "Minimizes error between idealized and actual filter response using Chebyshev polynomials with equiripple characteristics.",
                                    url: "https://en.wikipedia.org/wiki/Chebyshev_filter"
                                },
                                {
                                    title: "Elliptic Filter (Cauer Filter)",
                                    desc: "Employs Jacobian elliptic rational functions for equiripple behavior in both bands and the sharpest transition rolloff.",
                                    url: "https://en.wikipedia.org/wiki/Elliptic_filter"
                                },
                                {
                                    title: "Bessel Filter (Thomson Filter)",
                                    desc: "Optimized for maximally flat group delay and linear phase response, preserving pulses and waveforms without ringing.",
                                    url: "https://en.wikipedia.org/wiki/Bessel_filter"
                                },
                                {
                                    title: "Bilinear Transform",
                                    desc: "Conformal mapping of continuous s-plane into discrete z-plane via trapezoidal integration with frequency pre-warping.",
                                    url: "https://en.wikipedia.org/wiki/Bilinear_transform"
                                },
                                {
                                    title: "Digital Biquad Filter (Direct Form II Transposed)",
                                    desc: "Second-order IIR biquad section structure with 2 state delays per section, optimizing dynamic range and numerical stability.",
                                    url: "https://en.wikipedia.org/wiki/Digital_biquad_filter"
                                },
                                {
                                    title: "Group Delay & Phase Delay",
                                    desc: "Time delay of amplitude envelopes computed as the negative derivative of phase with respect to frequency.",
                                    url: "https://en.wikipedia.org/wiki/Group_delay_and_phase_delay"
                                },
                                {
                                    title: "Z-Transform & Stability Analysis",
                                    desc: "Complex discrete-time transform mapping stability to the interior of the unit circle |z| < 1.",
                                    url: "https://en.wikipedia.org/wiki/Z-transform"
                                }
                            ]
                            delegate: Column {
                                width: parent.width
                                spacing: 4

                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 3
                                        height: 14
                                        color: theme.accent
                                        radius: 1.5
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.title
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        color: theme.primaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Read Article ↗"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        font.underline: wHov.hovered
                                        color: theme.accent
                                        anchors.verticalCenter: parent.verticalCenter

                                        HoverHandler { id: wHov; cursorShape: Qt.PointingHandCursor }
                                        TapHandler { onTapped: Qt.openUrlExternally(modelData.url) }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    text: modelData.desc
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    color: theme.secondaryText
                                    wrapMode: Text.WordWrap
                                    leftPadding: 11
                                }
                            }
                        }
                    }

                    // ── 3. Topologies & Export Formats Reference ─────────────────────
                    Column {
                        width: parent.width
                        spacing: 12

                        Text {
                            text: "Synthesis Topologies & Code Exporters"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "• Lowpass (LPF): Passband [0, Fc], N zeros placed at z = -1 (Nyquist).\n• Highpass (HPF): Passband [Fc, Fs/2], N zeros placed at z = +1 (DC cancellation).\n• Bandpass (BPF): Passband [Fc1, Fc2], N zeros at z = +1 and N zeros at z = -1.\n• Bandstop (Notch): Rejection [Fc1, Fc2], zeros placed on unit circle at e^(±jω0).\n\nExport Targets:\n• Embedded C: Direct Form II Transposed biquad function with state struct.\n• Modern C++20: Vectorized biquad class with constexpr coefficient arrays.\n• Python (SciPy): Standalone script with signal.sosfilt and matplotlib verification.\n• JSON Schema: Machine-readable specification and second-order sections."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.5
                        }
                    }
                }
            }
        }
    }
}

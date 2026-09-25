import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

// DocsPage.qml — Clean modular docs: Get Started, Theory & Math with LaTeX, Step-by-Step Tutorials, and Reference Tables
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property bool isNarrow: width < 720
    readonly property int pageMargin: isNarrow ? 18 : 36

    property int activeTab: 0 // 0=Get Started, 1=Theory & Math, 2=Tutorials, 3=Reference Tables

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
            border.color: theme.borderColor
            border.width: 1
            z: 10

            Row {
                anchors.left: parent.left
                anchors.leftMargin: root.pageMargin
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: [
                        { label: "Get Started",        icon: "book" },
                        { label: "Theory & Math",      icon: "graph" },
                        { label: "Tutorials & Guides",  icon: "mortar-board" },
                        { label: "Technical Tables",   icon: "table" }
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
                // TAB 0: GET STARTED (VS Code Welcome Screen + Clean Theory on Start)
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
                                    { text: "Specification Tables...",      icon: "table",        tab: 3 }
                                ]
                                delegate: Row {
                                    spacing: 10
                                    height: 24

                                    Codicon {
                                        icon: modelData.icon
                                        iconSize: 15
                                        iconColor: startHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.text
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: startHov.hovered
                                        color: startHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter

                                        HoverHandler {
                                            id: startHov
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                        TapHandler {
                                            onTapped: {
                                                if (modelData.hasOwnProperty("tab")) {
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
                                            delegate: Rectangle {
                                                width: keyText.implicitWidth + 12
                                                height: 20
                                                radius: 4
                                                color: theme.isDark ? "#2A2D2E" : "#E4E4E4"
                                                border.color: theme.borderColor
                                                border.width: 1

                                                Text {
                                                    id: keyText
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    font.family: "Monospace"
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    color: theme.primaryText
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: modelData.label
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        color: scHov.hovered ? theme.primaryText : theme.secondaryText
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.underline: scHov.hovered

                                        HoverHandler {
                                            id: scHov
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                        TapHandler {
                                            onTapped: root.go(modelData.page)
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: 6
                                topPadding: 4

                                Codicon {
                                    icon: "link-external"
                                    iconSize: 12
                                    iconColor: moreHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "More guides & tables..."
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: moreHov.hovered
                                    color: moreHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter

                                    HoverHandler {
                                        id: moreHov
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                    TapHandler {
                                        onTapped: {
                                            root.activeTab = 3
                                            docFlick.contentY = 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 1: THEORY & MATHEMATICS (Dedicated Math Page with LaTeX)
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
                            renderedHtml: "<i>s</i><sub><i>k</i></sub> = exp<span style=\"font-size:15px;\">(</span><i>j</i> &middot; <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 2px;\">&pi;(2<i>k</i> + <i>n</i> &minus; 1)</td></tr><tr><td style=\"padding:0 2px;\">2<i>n</i></td></tr></table><span style=\"font-size:15px;\">)</span>, &nbsp;&nbsp; <i>k</i> = 1, 2, ..., <i>n</i>"
                            latexSource: "s_k = \\exp\\left( j \\frac{\\pi(2k + n - 1)}{2n} \\right), \\quad k = 1, \\dots, n"
                        }

                        Text {
                            width: parent.width
                            text: "• Chebyshev Type I: Poles placed on an ellipse with minor axis sinh(a) and major axis cosh(a), where a = asinh(1/ε)/n. Minimizes maximum peak error in the passband.\n• Chebyshev Type II: Inverted prototype poles with finite transmission zeros placed along the imaginary jΩ axis at zeros zk = ±j / cos(θk).\n• Elliptic (Cauer): Employs Jacobian elliptic rational functions to produce equiripple behavior in both passband and stopband with the steepest transition bandwidth.\n• Bessel (Thomson): Roots derived from reverse Bessel polynomials yn(s) to maximize group delay flatness and eliminate waveform ringing."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
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
                            renderedHtml: "<i>s</i> = <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 3px;\">2</td></tr><tr><td style=\"padding:0 3px;\"><i>T</i></td></tr></table> <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 3px;\">1 &minus; <i>z</i><sup>&minus;1</sup></td></tr><tr><td style=\"padding:0 3px;\">1 + <i>z</i><sup>&minus;1</sup></td></tr></table> &nbsp;&hArr;&nbsp; &Omega; = 2<i>f</i><sub><i>s</i></sub> tan<span style=\"font-size:15px;\">(</span><table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 2px;\">&pi;<i>f</i><sub><i>c</i></sub></td></tr><tr><td style=\"padding:0 2px;\"><i>f</i><sub><i>s</i></sub></td></tr></table><span style=\"font-size:15px;\">)</span>"
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
                            text: "Direct realization of high-order transfer functions suffers from severe numerical coefficient sensitivity. Overtune 3 groups complex roots into strict conjugate pairs (p, p*) to ensure purely real biquad coefficients:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq5"
                            title: "Second-Order Section (SOS) Cascade"
                            equationNumber: "(5)"
                            renderedHtml: "<i>H</i>(<i>z</i>) = <i>g</i> &middot; &prod;<sub><i>k</i>=1</sub><sup><i>K</i></sup> <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 4px;\"><i>b</i><sub>0,<i>k</i></sub> + <i>b</i><sub>1,<i>k</i></sub><i>z</i><sup>&minus;1</sup> + <i>b</i><sub>2,<i>k</i></sub><i>z</i><sup>&minus;2</sup></td></tr><tr><td style=\"padding:0 4px;\">1 + <i>a</i><sub>1,<i>k</i></sub><i>z</i><sup>&minus;1</sup> + <i>a</i><sub>2,<i>k</i></sub><i>z</i><sup>&minus;2</sup></td></tr></table>"
                            latexSource: "H(z) = g \\cdot \\prod_{k=1}^{K} \\frac{b_{0,k} + b_{1,k} z^{-1} + b_{2,k} z^{-2}}{1 + a_{1,k} z^{-1} + a_{2,k} z^{-2}}"
                        }

                        Text {
                            width: parent.width
                            text: "For each conjugate pole pair p = r·e^(±jθ), the denominator coefficients are calculated as a1 = -2·r·cos(θ) and a2 = r². Sections are ordered by ascending pole radius (low Q first) to maximize signal-to-noise ratio and prevent internal state overflow."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }
                    }

                    // Section 4: Exact Group Delay
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "4. Exact Analytical Group Delay"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "Instead of noisy finite-difference numerical approximations, Overtune 3 computes exact analytical derivatives of the unwrapped phase response across all biquad stages:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq6"
                            title: "Analytical Phase Derivative Group Delay"
                            equationNumber: "(6)"
                            renderedHtml: "&tau;<sub><i>g</i></sub>(&omega;) = &minus;<table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 2px;\"><i>d</i>&theta;(&omega;)</td></tr><tr><td style=\"padding:0 2px;\"><i>d</i>&omega;</td></tr></table> = &sum;<sub><i>k</i>=1</sub><sup><i>K</i></sup> <span style=\"font-size:15px;\">[</span> <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 3px;\"><i>P</i><sub><i>a</i>,<i>k</i></sub>(&omega;)</td></tr><tr><td style=\"padding:0 3px;\">|<i>A</i><sub><i>k</i></sub>(<i>e</i><sup><i>j&omega;</i></sup>)|<sup>2</sup></td></tr></table> &minus; <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 3px;\"><i>P</i><sub><i>b</i>,<i>k</i></sub>(&omega;)</td></tr><tr><td style=\"padding:0 3px;\">|<i>B</i><sub><i>k</i></sub>(<i>e</i><sup><i>j&omega;</i></sup>)|<sup>2</sup></td></tr></table> <span style=\"font-size:15px;\">]</span>"
                            latexSource: "\\tau_g(\\omega) = -\\frac{d\\theta(\\omega)}{d\\omega} = \\sum_{k=1}^{K} \\left[ \\frac{P_{a,k}(\\omega)}{|A_k(e^{j\\omega})|^2} - \\frac{P_{b,k}(\\omega)}{|B_k(e^{j\\omega})|^2} \\right]"
                        }
                    }

                    // Section 5: Stability Condition
                    Column {
                        width: parent.width
                        spacing: 10

                        Text {
                            text: "5. Stability Criterion in the Complex Z-Domain"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                        }

                        Text {
                            width: parent.width
                            text: "A causal digital IIR filter is Bounded-Input Bounded-Output (BIBO) stable if and only if all system poles lie strictly inside the complex unit circle |z| < 1:"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                            wrapMode: Text.WordWrap
                            lineHeight: 1.45
                        }

                        LaTeXBlock {
                            width: parent.width
                            eqId: "eq7"
                            title: "Unit Circle Stability Bound"
                            equationNumber: "(7)"
                            renderedHtml: "max<sub><i>k</i></sub> |<i>p</i><sub><i>k</i></sub>| &lt; 1.0 &nbsp;&hArr;&nbsp; &forall; <i>k</i>, &nbsp; <i>p</i><sub><i>k</i></sub> &isin; <font face=\"serif\">&Popf;</font> = { <i>z</i> &isin; <font face=\"serif\">&Copf;</font> : |<i>z</i>| &lt; 1 }"
                            latexSource: "\\max_{k} |p_k| < 1.0 \\iff \\forall k, \\; p_k \\in \\mathbb{D} = \\{ z \\in \\mathbb{C} : |z| < 1 \\}"
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
                        text: "Practical, production-tested guides for designing, analyzing, simulating, and deploying digital filters across audio, instrumentation, and embedded firmware applications."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                    }

                    // ── Tutorial 1: Studio Audio Lowpass ───────────────────────────
                    Rectangle {
                        width: parent.width
                        implicitHeight: t1Col.implicitHeight + 36
                        height: implicitHeight
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: t1Col
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 18
                            }
                            spacing: 14

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: t1Tag.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#1C2D3D" : "#E1EFFF"
                                    Text {
                                        id: t1Tag
                                        anchors.centerIn: parent
                                        text: "Audio Engineering"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: theme.accent
                                    }
                                }

                                Text {
                                    text: "Difficulty: Beginner  •  Duration: 4 min"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "Tutorial 1: Studio Audio Lowpass & High-Frequency Denoising"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

                            Text {
                                width: parent.width
                                text: "Goal: Remove unwanted high-frequency tape hiss and air noise above 12,000 Hz from a 48 kHz studio vocal recording without introducing phase smearing or audible transients."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            // Parameter Specs Matrix
                            Rectangle {
                                width: parent.width
                                implicitHeight: Math.max(56, t1MatrixRow.implicitHeight + 16)
                                height: implicitHeight
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    id: t1MatrixRow
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 8
                                    }

                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Topology"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Lowpass (LPF)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Approximation"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Butterworth / Bessel"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Order (N)"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "4th Order (2 Biquads)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Cutoff / Sample Rate"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Fc = 12 kHz, Fs = 48 kHz"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "Step-by-Step Instructions:\n1. Open the Filter Designer Studio workspace.\n2. Select Lowpass (LPF) from the Topology selector, and Butterworth from the Response Type selector.\n3. Adjust the Order slider to 4, Cutoff Frequency (Fc) to 12,000 Hz, and Sampling Rate (Fs) to 48,000 Hz.\n4. Observe the interactive Magnitude response: the -3 dB corner aligns precisely at 12 kHz with a monotonic 24 dB/octave rolloff.\n5. Navigate to the Signal Simulation Studio, choose the Audio WAV tab, and import your recording to audition the filtered signal in real-time."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            // Clean Hyperlinks
                            Row {
                                spacing: 20
                                topPadding: 4

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t1Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Launch Filter Designer Studio"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t1Hov.hovered
                                        color: t1Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t1Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(0) }
                                }

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t1SimHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Open Signal Simulation Studio"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t1SimHov.hovered
                                        color: t1SimHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t1SimHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(2) }
                                }
                            }
                        }
                    }

                    // ── Tutorial 2: Mains Hum 50/60 Hz Notch Filter ────────────────
                    Rectangle {
                        width: parent.width
                        implicitHeight: t2Col.implicitHeight + 36
                        height: implicitHeight
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: t2Col
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 18
                            }
                            spacing: 14

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: t2Tag.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#2A1C3D" : "#F4EAFF"
                                    Text {
                                        id: t2Tag
                                        anchors.centerIn: parent
                                        text: "Signal Conditioning"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: theme.isDark ? "#D2A8FF" : "#8A3FFC"
                                    }
                                }

                                Text {
                                    text: "Difficulty: Intermediate  •  Duration: 5 min"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "Tutorial 2: 50 Hz / 60 Hz Electrical Ground Loop Notch Filter"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

                            Text {
                                width: parent.width
                                text: "Goal: Eliminate 50 Hz or 60 Hz AC electrical mains interference from sensitive sensor telemetry or audio signals while keeping bass frequencies (40 Hz - 70 Hz) completely intact."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            // Parameter Specs Matrix
                            Rectangle {
                                width: parent.width
                                implicitHeight: Math.max(56, t2MatrixRow.implicitHeight + 16)
                                height: implicitHeight
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    id: t2MatrixRow
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 8
                                    }

                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Topology"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Bandstop (Notch)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Approximation"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Elliptic (Cauer)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Bandwidth (Fc1, Fc2)"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "49 Hz to 51 Hz (2 Hz BW)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Rejection / Sampling"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Rs = 60 dB, Fs = 44.1 kHz"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "Step-by-Step Instructions:\n1. In Filter Designer Studio, select Bandstop (Notch) Topology.\n2. Choose Elliptic Response for maximum notch selectivity.\n3. Configure Lower Cutoff Fc1 = 49 Hz and Upper Cutoff Fc2 = 51 Hz (for 50 Hz mains) or 59/61 Hz (for 60 Hz mains).\n4. Set Stopband Attenuation to 60 dB and Order to 4.\n5. Switch to Frequency Analysis Suite: inspect the Z-Plane pole-zero diagram. Notice the zeros positioned directly on the unit circle (|z| = 1.0) at the angular frequency ω = 2π(50/44100), ensuring mathematical -inf dB cancellation at the mains frequency."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            // Clean Hyperlinks
                            Row {
                                spacing: 20
                                topPadding: 4

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t2Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Configure in Designer Studio"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t2Hov.hovered
                                        color: t2Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t2Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(0) }
                                }

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t2AnHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Inspect Poles in Frequency Analysis Suite"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t2AnHov.hovered
                                        color: t2AnHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t2AnHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(1) }
                                }
                            }
                        }
                    }

                    // ── Tutorial 3: Speech Bandpass ITU-T G.712 ────────────────────
                    Rectangle {
                        width: parent.width
                        implicitHeight: t3Col.implicitHeight + 36
                        height: implicitHeight
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: t3Col
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 18
                            }
                            spacing: 14

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: t3Tag.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#1C3D27" : "#E6F4EA"
                                    Text {
                                        id: t3Tag
                                        anchors.centerIn: parent
                                        text: "Communications DSP"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#30D158"
                                    }
                                }

                                Text {
                                    text: "Difficulty: Intermediate  •  Duration: 5 min"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "Tutorial 3: Telephony & Voice Bandpass Filter (ITU-T G.712 Standard)"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

                            Text {
                                width: parent.width
                                text: "Goal: Design a 300 Hz to 3,400 Hz voice telephony bandpass filter complying with telecommunications channel transmission standards to reject DC bias and out-of-band acoustic noise."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            // Parameter Specs Matrix
                            Rectangle {
                                width: parent.width
                                implicitHeight: Math.max(56, t3MatrixRow.implicitHeight + 16)
                                height: implicitHeight
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    id: t3MatrixRow
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 8
                                    }

                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Topology"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Bandpass (BPF)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Passband Range"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "300 Hz to 3,400 Hz"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Approximation"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Chebyshev Type I"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Order / Ripple"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Order 6, Ripple 0.5 dB"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "Step-by-Step Instructions:\n1. Select Bandpass (BPF) Topology and Chebyshev Type I response.\n2. Set Lower Cutoff Fc1 = 300 Hz and Upper Cutoff Fc2 = 3,400 Hz, with Order = 6 and Sampling Rate Fs = 16,000 Hz.\n3. Verify the Passband Ripple is under 0.5 dB across the 300-3400 Hz interval.\n4. Check the Analytical Group Delay in Analysis View: verify delay variation is less than 0.8 ms in the critical 500-2500 Hz speech formant region to ensure intelligibility."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            // Clean Hyperlinks
                            Row {
                                spacing: 20
                                topPadding: 4

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t3Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Design Telephony Filter in Studio"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t3Hov.hovered
                                        color: t3Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t3Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(0) }
                                }

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t3ExpHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Export Biquads in Code Exporter"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t3ExpHov.hovered
                                        color: t3ExpHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t3ExpHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(3) }
                                }
                            }
                        }
                    }

                    // ── Tutorial 4: Embedded C & C++20 Firmware Integration ─────────
                    Rectangle {
                        width: parent.width
                        implicitHeight: t4Col.implicitHeight + 36
                        height: implicitHeight
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1

                        Column {
                            id: t4Col
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 18
                            }
                            spacing: 14

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: t4Tag.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#3D2B1C" : "#FFF3E6"
                                    Text {
                                        id: t4Tag
                                        anchors.centerIn: parent
                                        text: "Embedded Systems"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: "#FF9500"
                                    }
                                }

                                Text {
                                    text: "Difficulty: Advanced  •  Duration: 7 min"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 11
                                    color: theme.secondaryText
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Text {
                                text: "Tutorial 4: Bare-Metal Microcontroller C & Modern C++20 Integration"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: theme.primaryText
                            }

                            Text {
                                width: parent.width
                                text: "Goal: Deploy synthesized biquad coefficients into an ARM Cortex-M or microcontroller DMA audio buffer callback with zero dynamic heap allocation and deterministic cycle count."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            Text {
                                width: parent.width
                                text: "Step-by-Step Instructions:\n1. Design your target filter in Filter Designer Studio.\n2. Open the Production Code Exporter workspace.\n3. Choose Embedded C or Modern C++20 from the format selector.\n4. Click 'Copy Code' to place the complete standalone implementation into your clipboard.\n5. Paste the generated struct into your firmware project. The biquad processing loop uses Direct Form II Transposed equations requiring only 2 state variables per biquad:"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            // Direct Form II Transposed Code Snippet
                            Rectangle {
                                width: parent.width
                                implicitHeight: cCodeCol.implicitHeight + 16
                                radius: 4
                                color: theme.isDark ? "#141414" : "#F4F4F4"
                                border.color: theme.borderColor
                                border.width: 1

                                Column {
                                    id: cCodeCol
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 3

                                    Text {
                                        text: "// Direct Form II Transposed processing loop (zero heap allocation)\nfloat biquad_process(Biquad* s, float in) {\n    float out = s->b0 * in + s->w1;\n    s->w1 = s->b1 * in - s->a1 * out + s->w2;\n    s->w2 = s->b2 * in - s->a2 * out;\n    return out;\n}"
                                        font.family: "Monospace"
                                        font.pixelSize: 11
                                        color: theme.isDark ? "#9CDCFE" : "#001080"
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }

                            // Clean Hyperlinks
                            Row {
                                spacing: 20
                                topPadding: 4

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t4ExpHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Open Production Code Exporter"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t4ExpHov.hovered
                                        color: t4ExpHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t4ExpHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(3) }
                                }

                                Row {
                                    spacing: 6
                                    Codicon {
                                        icon: "link-external"
                                        iconSize: 12
                                        iconColor: t4DesHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: "Tune Parameters in Filter Designer Studio"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        font.underline: t4DesHov.hovered
                                        color: t4DesHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    HoverHandler { id: t4DesHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(0) }
                                }
                            }
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 3: SYMMETRIC REFERENCE TABLES (Dedicated Tables Page)
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 24
                    visible: root.activeTab === 3

                    Text {
                        text: "Technical Reference & Specification Tables"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                        color: theme.primaryText
                    }

                    // Table 1: Workspaces
                    Column {
                        width: parent.width
                        spacing: 0

                        Text {
                            text: "1. Core Application Workspaces Matrix"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                            bottomPadding: 8
                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            color: theme.isDark ? "#252526" : "#EBEBEB"
                            border.color: theme.borderColor
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text { width: parent.width * 0.28; text: "Workspace Route"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.46; text: "Controls & Specifications"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.26; text: "Action"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }

                        Repeater {
                            model: [
                                { route: "Filter Designer Studio",   desc: "Topology, Response Type, Order (1..10), Cutoff Frequencies (Fc, Fc2), Sample Rate (Fs), Passband Ripple, Stopband Attenuation", page: 0 },
                                { route: "Frequency Analysis Suite", desc: "Magnitude in dB, Unwrapped Continuous Phase in Degrees, Exact Analytical Group Delay in Samples, Z-Plane Pole-Zero Constellation", page: 1 },
                                { route: "Signal Simulation Studio", desc: "Sine Waves, Frequency Chirps (20Hz-20kHz), Square Waves, White Noise, 16/24-bit PCM WAV Import, Real-time Audio Playback", page: 2 },
                                { route: "Production Code Exporter", desc: "Embedded C (Direct Form II Transposed), C++20 Header-Only Struct, Python SciPy SOS Matrix, Machine-Readable JSON Schema", page: 3 },
                                { route: "Workspace Settings",       desc: "Dark / Light Theme Toggle, Sampling Rate Defaults, Export Configuration, Application Version Information", page: 5 }
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: 38
                                color: rowHov.hovered ? (theme.isDark ? "#222526" : "#F5F5F5") : (index % 2 === 0 ? "transparent" : (theme.isDark ? "#1C1C1D" : "#FAFAFA"))
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text { width: parent.width * 0.28; text: modelData.route; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.46; text: modelData.desc; font.family: "Stack Sans Headline"; font.pixelSize: 12; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                    
                                    Row {
                                        width: parent.width * 0.26
                                        spacing: 6
                                        anchors.verticalCenter: parent.verticalCenter

                                        Codicon {
                                            icon: "link-external"
                                            iconSize: 12
                                            iconColor: actHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Text {
                                            text: "Open Workspace"
                                            font.family: "Stack Sans Headline"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            font.underline: actHov.hovered
                                            color: actHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    HoverHandler { id: actHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(modelData.page) }
                                }
                                HoverHandler { id: rowHov }
                            }
                        }
                    }

                    // Table 2: Topologies
                    Column {
                        width: parent.width
                        spacing: 0

                        Text {
                            text: "2. Supported Topologies & Zero Distributions"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                            bottomPadding: 8
                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            color: theme.isDark ? "#252526" : "#EBEBEB"
                            border.color: theme.borderColor
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text { width: parent.width * 0.22; text: "Topology"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.28; text: "Passband Range"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.28; text: "Stopband Range"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.22; text: "Z-Domain Zeros"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }

                        Repeater {
                            model: [
                                { top: "Lowpass (LPF)",    pb: "0  ≤  f  ≤  Fc",       sb: "Fc  <  f  ≤  Fs/2",      zeros: "N zeros at z = -1 (Nyquist)" },
                                { top: "Highpass (HPF)",   pb: "Fc  ≤  f  ≤  Fs/2",    sb: "0  ≤  f  <  Fc",         zeros: "N zeros at z = +1 (DC Rejection)" },
                                { top: "Bandpass (BPF)",   pb: "Fc1  ≤  f  ≤  Fc2",    sb: "f < Fc1  and  f > Fc2",  zeros: "N zeros at z = +1, N at z = -1" },
                                { top: "Bandstop (Notch)", pb: "f < Fc1  and  f > Fc2", sb: "Fc1  ≤  f  ≤  Fc2",    zeros: "2N zeros on unit circle at e^(±jω0)" }
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: 36
                                color: t2Hov.hovered ? (theme.isDark ? "#222526" : "#F5F5F5") : (index % 2 === 0 ? "transparent" : (theme.isDark ? "#1C1C1D" : "#FAFAFA"))
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text { width: parent.width * 0.22; text: modelData.top; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.28; text: modelData.pb; font.family: "Monospace"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.28; text: modelData.sb; font.family: "Monospace"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.22; text: modelData.zeros; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.accent; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                }
                                HoverHandler { id: t2Hov }
                            }
                        }
                    }

                    // Table 3: Approximation Types
                    Column {
                        width: parent.width
                        spacing: 0

                        Text {
                            text: "3. Approximation Types & Mathematical Comparison"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                            bottomPadding: 8
                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            color: theme.isDark ? "#252526" : "#EBEBEB"
                            border.color: theme.borderColor
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text { width: parent.width * 0.20; text: "Approximation"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.25; text: "Passband Profile"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.25; text: "Stopband Profile"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.30; text: "Phase & Group Delay"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }

                        Repeater {
                            model: [
                                { name: "Butterworth",     pb: "Maximally Flat (0 dB ripple)", sb: "Monotonic rolloff",    gd: "Moderate non-linearity" },
                                { name: "Chebyshev I",     pb: "Equiripple (±Rp dB)",          sb: "Monotonic rolloff",    gd: "Non-linear near cutoff" },
                                { name: "Chebyshev II",    pb: "Maximally Flat",               sb: "Equiripple (-Rs dB)",  gd: "Non-linear near cutoff" },
                                { name: "Elliptic (Cauer)", pb: "Equiripple (±Rp dB)",         sb: "Equiripple (-Rs dB)",  gd: "Steep non-linear delay" },
                                { name: "Bessel (Thomson)", pb: "Smooth gradual rolloff",      sb: "Gentle attenuation",   gd: "Maximally Flat (Linear Phase)" }
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: 36
                                color: t3Hov.hovered ? (theme.isDark ? "#222526" : "#F5F5F5") : (index % 2 === 0 ? "transparent" : (theme.isDark ? "#1C1C1D" : "#FAFAFA"))
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text { width: parent.width * 0.20; text: modelData.name; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.25; text: modelData.pb; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.25; text: modelData.sb; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.30; text: modelData.gd; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                }
                                HoverHandler { id: t3Hov }
                            }
                        }
                    }

                    // Table 4: Code Export Specification
                    Column {
                        width: parent.width
                        spacing: 0

                        Text {
                            text: "4. Production Code Export Formats"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: theme.primaryText
                            bottomPadding: 8
                        }

                        Rectangle {
                            width: parent.width
                            height: 32
                            color: theme.isDark ? "#252526" : "#EBEBEB"
                            border.color: theme.borderColor
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text { width: parent.width * 0.22; text: "Target Format"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.38; text: "Architecture & Implementation"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                Text { width: parent.width * 0.40; text: "Target Environments"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }
                        }

                        Repeater {
                            model: [
                                { lang: "Embedded C",   arch: "Direct Form II Transposed biquad cascade with static state array", env: "ARM Cortex-M, STM32, ESP32, MISRA-C" },
                                { lang: "Modern C++20",  arch: "Templated constexpr struct with zero-allocation buffers",        env: "JUCE audio plugins, VST3/AU, game audio" },
                                { lang: "Python SciPy", arch: "6-column Second-Order Section matrix for scipy.signal.sosfilt",  env: "NumPy, SciPy, Jupyter research pipelines" },
                                { lang: "JSON Schema",  arch: "Serialized biquad sections, poles, zeros, and gain object",      env: "Automated test suites, CI/CD, web APIs" }
                            ]
                            delegate: Rectangle {
                                width: parent.width
                                height: 36
                                color: t4Hov.hovered ? (theme.isDark ? "#222526" : "#F5F5F5") : (index % 2 === 0 ? "transparent" : (theme.isDark ? "#1C1C1D" : "#FAFAFA"))
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12

                                    Text { width: parent.width * 0.22; text: modelData.lang; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                    Text { width: parent.width * 0.38; text: modelData.arch; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                    Text { width: parent.width * 0.40; text: modelData.env; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.accent; anchors.verticalCenter: parent.verticalCenter; elide: Text.ElideRight }
                                }
                                HoverHandler { id: t4Hov }
                            }
                        }
                    }
                }
            }
        }
    }
}

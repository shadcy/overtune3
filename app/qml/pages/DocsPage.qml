import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "../components"

// DocsPage.qml — Clean unified docs: Get Started, Theory & Math with LaTeX, Tutorials, and Contributors & Wiki
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

                    // Clean Theory Provided on Start
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: 18
                            }
                            topPadding: 16
                            bottomPadding: 16
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
                                    font.pixelSize: 14
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

                            // LaTeX Mathematical Equation Block on Start
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
                                renderedHtml: "<i>H</i>(<i>z</i>) = <i>g</i> &middot; &prod;<sub><i>k</i>=1</sub><sup><i>K</i></sup> <table style=\"display:inline-table;vertical-align:middle;text-align:center;\"><tr><td style=\"border-bottom:1px solid #777;padding:0 4px;\"><i>b</i><sub>0,<i>k</i></sub> + <i>b</i><sub>1,<i>k</i></sub><i>z</i><sup>&minus;1</sup> + <i>b</i><sub>2,<i>k</i></sub><i>z</i><sup>&minus;2</sup></td></tr><tr><td style=\"padding:0 4px;\">1 + <i>a</i><sub>1,<i>k</i></sub><i>z</i><sup>&minus;1</sup> + <i>a</i><sub>2,<i>k</i></sub><i>z</i><sup>&minus;2</sup></td></tr></table>"
                                latexSource: "H(z) = g \\cdot \\prod_{k=1}^{K} \\frac{b_{0,k} + b_{1,k} z^{-1} + b_{2,k} z^{-2}}{1 + a_{1,k} z^{-1} + a_{2,k} z^{-2}}"
                            }
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
                                    { text: "Contributors & Wiki...",       icon: "organization", tab: 3 }
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
                // TAB 1: THEORY & MATHEMATICS (Unified Card Style)
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 20
                    visible: root.activeTab === 1

                    // Headline
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "DSP Theory & Mathematical Foundations"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: theme.primaryText
                        }

                        Text {
                            text: "Rigorous mathematical derivations for continuous-time filter prototypes, bilinear frequency warping, and discrete second-order cascade realizations."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                        }
                    }

                    // Card 1: Analog Prototype Syntheses
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                spacing: 8
                                Codicon { icon: "graph"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "1. Analog Prototype Syntheses"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Digital IIR filters are synthesized by calculating the complex poles and zeros of classical normalized analog prototypes (Ωc = 1 rad/s). The poles for an n-th order Butterworth prototype lie uniformly distributed along the left-half unit circle in the complex s-plane:"
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
                                text: "• Butterworth: Maximally flat magnitude response in passband with monotonic attenuation (6N dB/octave).\n• Chebyshev Type I: Equiripple passband with steep roll-off, minimizing maximum peak ripple error.\n• Chebyshev Type II: Maximally flat passband with transmission zeros placed along the imaginary jΩ axis.\n• Elliptic (Cauer): Jacobian elliptic rational functions producing the sharpest possible transition bandwidth.\n• Bessel (Thomson): Maximally flat group delay, preserving waveforms with linear phase and zero ringing."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }
                        }
                    }

                    // Card 2: Bilinear Transform & Pre-Warping
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                spacing: 8
                                Codicon { icon: "sync"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "2. Bilinear Transform with Tangent Pre-Warping"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
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
                    }

                    // Card 3: SOS Conjugate Pairing
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                spacing: 8
                                Codicon { icon: "layers"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "3. Second-Order Section (SOS) Conjugate Pairing"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
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
                    }

                    // Card 4: Group Delay & Unit Circle Stability
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                spacing: 8
                                Codicon { icon: "pulse"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "4. Group Delay & Stability Criteria"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Group delay represents the transit delay of envelope information across frequencies. A causal digital IIR filter is Bounded-Input Bounded-Output (BIBO) stable if and only if all system poles lie strictly inside the complex unit circle |z| < 1:"
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
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 2: STEP-BY-STEP TUTORIALS (Unified Card Style)
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 20
                    visible: root.activeTab === 2

                    // Headline
                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "Step-by-Step DSP Workflow Tutorials"
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 22
                            font.weight: Font.Bold
                            color: theme.primaryText
                        }

                        Text {
                            text: "Practical guides and interactive learning modules covering audio denoising, mains hum rejection, speech bandpassing, and microcontroller firmware integration."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                        }
                    }

                    // Tutorial Studio Widget
                    TutorialStudio {
                        width: parent.width
                    }

                    Text {
                        text: "Guided Filter Workflows"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        color: theme.primaryText
                        topPadding: 8
                    }

                    // Card 1: Studio Audio Lowpass
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: tag1Text.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#1C2D3D" : "#E1EFFF"
                                    Text {
                                        id: tag1Text
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

                            Row {
                                spacing: 8
                                Codicon { icon: "radio-tower"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Workflow 1: Studio Audio Lowpass & Noise Reduction"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Remove unwanted high-frequency tape hiss and air noise above 12,000 Hz from a 48 kHz studio recording without introducing audible ringing or phase distortion."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            // Specs Summary Box
                            Rectangle {
                                width: parent.width
                                height: 48
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8

                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Topology"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Lowpass (LPF)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Approximation"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Butterworth"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Order (N)"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Order 4 (2 Biquads)"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
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
                                text: "Step-by-Step Instructions:\n1. Open Filter Designer Studio, select Lowpass (LPF), and choose Butterworth response.\n2. Set Order = 4, Cutoff Frequency = 12,000 Hz, and Sampling Rate = 48,000 Hz.\n3. Verify the -3 dB corner aligns at 12 kHz with a smooth 24 dB/octave attenuation slope.\n4. Audition audio in Signal Simulation Studio to verify hiss reduction in real time."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            Row {
                                spacing: 6
                                topPadding: 4
                                Codicon { icon: "link-external"; iconSize: 12; iconColor: wf1Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "Configure in Filter Designer Studio ↗"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: wf1Hov.hovered
                                    color: wf1Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                    HoverHandler { id: wf1Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(0) }
                                }
                            }
                        }
                    }

                    // Card 2: Mains Hum Notch
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: tag2Text.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#1C2D3D" : "#E1EFFF"
                                    Text {
                                        id: tag2Text
                                        anchors.centerIn: parent
                                        text: "Signal Conditioning"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: theme.accent
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

                            Row {
                                spacing: 8
                                Codicon { icon: "zap"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Workflow 2: 50 Hz / 60 Hz Ground Loop Notch Rejection"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Eliminate 50 Hz or 60 Hz electrical mains interference from sensitive sensor telemetry or audio signals while keeping bass frequencies intact."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            Rectangle {
                                width: parent.width
                                height: 48
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8

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
                                        Text { text: "Notch Bandwidth"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Fc1=49Hz, Fc2=51Hz"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                    Column {
                                        width: parent.width * 0.25; spacing: 2
                                        Text { text: "Rejection / Order"; font.family: "Stack Sans Headline"; font.pixelSize: 11; color: theme.secondaryText }
                                        Text { text: "Rs = 60 dB, Order 4"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText }
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "Step-by-Step Instructions:\n1. Choose Bandstop (Notch) Topology and Elliptic response.\n2. Set Fc1 = 49 Hz, Fc2 = 51 Hz, Order = 4, and Stopband Attenuation = 60 dB.\n3. Open Frequency Analysis Suite and observe transmission zeros placed on the unit circle (|z| = 1.0) providing mathematical cancellation at mains frequency."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            Row {
                                spacing: 6
                                topPadding: 4
                                Codicon { icon: "link-external"; iconSize: 12; iconColor: wf2Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "Open Frequency Analysis Suite ↗"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: wf2Hov.hovered
                                    color: wf2Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                    HoverHandler { id: wf2Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(1) }
                                }
                            }
                        }
                    }

                    // Card 3: Telephony Bandpass
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: tag3Text.implicitWidth + 10
                                    height: 22
                                    radius: 4
                                    color: theme.isDark ? "#1C2D3D" : "#E1EFFF"
                                    Text {
                                        id: tag3Text
                                        anchors.centerIn: parent
                                        text: "Communications DSP"
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: theme.accent
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

                            Row {
                                spacing: 8
                                Codicon { icon: "call-incoming"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Workflow 3: Voice Telephony Bandpass (ITU-T G.712)"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Design a 300 Hz to 3,400 Hz voice telephony bandpass filter complying with telecommunications standards to reject DC drift and out-of-band acoustic noise."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.45
                            }

                            Rectangle {
                                width: parent.width
                                height: 48
                                radius: 4
                                color: theme.isDark ? "#1A1A1A" : "#F6F8FA"
                                border.color: theme.borderColor
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8

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
                                text: "Step-by-Step Instructions:\n1. Select Bandpass (BPF) Topology and Chebyshev Type I response.\n2. Set Fc1 = 300 Hz, Fc2 = 3,400 Hz, Order = 6, and Sampling Rate Fs = 16,000 Hz.\n3. Verify Passband Ripple is under 0.5 dB and check Group Delay across the 500-2,500 Hz formant region."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.primaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            Row {
                                spacing: 6
                                topPadding: 4
                                Codicon { icon: "link-external"; iconSize: 12; iconColor: wf3Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: "Export Production Code ↗"
                                    font.family: "Stack Sans Headline"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    font.underline: wf3Hov.hovered
                                    color: wf3Hov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                    HoverHandler { id: wf3Hov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: root.go(3) }
                                }
                            }
                        }
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 3: CONTRIBUTORS & WIKI (Unified Card Style)
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 20
                    visible: root.activeTab === 3

                    // Headline
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
                            text: "Open-source community repository links, contribution pathways, and direct Wikipedia reference articles for digital filter approximations."
                            font.family: "Stack Sans Headline"
                            font.pixelSize: 13
                            color: theme.secondaryText
                        }
                    }

                    // Card 1: Contributors & Community
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 14

                            Row {
                                spacing: 8
                                Codicon { icon: "organization"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Contributors & Community"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
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

                            // GitHub Action Buttons
                            Row {
                                spacing: 14

                                Rectangle {
                                    width: rBtnText.implicitWidth + 24
                                    height: 32
                                    radius: 4
                                    color: rHov.hovered ? (theme.isDark ? "#2A2D2E" : "#E8E8E8") : "transparent"
                                    border.color: theme.accent
                                    border.width: 1

                                    Row {
                                        id: rBtnText
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Codicon { icon: "github"; iconSize: 14; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "GitHub Repository"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                    }

                                    HoverHandler { id: rHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: Qt.openUrlExternally("https://github.com/shadcy/overtune3") }
                                }

                                Rectangle {
                                    width: iBtnText.implicitWidth + 24
                                    height: 32
                                    radius: 4
                                    color: iHov.hovered ? (theme.isDark ? "#2A2D2E" : "#E8E8E8") : "transparent"
                                    border.color: theme.accent
                                    border.width: 1

                                    Row {
                                        id: iBtnText
                                        anchors.centerIn: parent
                                        spacing: 8
                                        Codicon { icon: "issue-opened"; iconSize: 14; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "Report Issues & Feedback"; font.family: "Stack Sans Headline"; font.pixelSize: 12; font.weight: Font.Medium; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                                    }

                                    HoverHandler { id: iHov; cursorShape: Qt.PointingHandCursor }
                                    TapHandler { onTapped: Qt.openUrlExternally("https://github.com/shadcy/overtune3/issues") }
                                }
                            }

                            Text {
                                width: parent.width
                                text: "How You Can Contribute:\n• DSP Core Algorithms: Implement new analog prototypes (Legendre, Papoulis Optimum L, Gaussian) or FIR Parks-McClellan routines in pure C++20.\n• Numerical Optimization: Improve bilinear transformation precision and high-order SOS stability.\n• Audio Simulation: Enhance multi-channel WAV playback and spectral analysis visualizations.\n• Interactive Tutorials: Author student guides and practical presets via Tutorial Studio."
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                color: theme.secondaryText
                                wrapMode: Text.WordWrap
                                lineHeight: 1.5
                            }

                            Text {
                                text: "Maintainer: shadcy (https://github.com/shadcy)  •  License: MIT"
                                font.family: "Monospace"
                                font.pixelSize: 11
                                color: theme.accent
                            }
                        }
                    }

                    // Card 2: Wikipedia Reference Articles
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 14

                            Row {
                                spacing: 8
                                Codicon { icon: "book"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Wikipedia Reference Articles"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Direct links to Wikipedia documentation for in-depth proofs, historical context, and continuous-to-discrete filter mathematics:"
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
                                    spacing: 3

                                    Row {
                                        spacing: 8
                                        Codicon { icon: "link-external"; iconSize: 12; iconColor: artHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                        Text {
                                            text: modelData.title + " ↗"
                                            font.family: "Stack Sans Headline"
                                            font.pixelSize: 13
                                            font.weight: Font.DemiBold
                                            font.underline: artHov.hovered
                                            color: artHov.hovered ? (theme.isDark ? "#4FC1FF" : "#005FB8") : theme.accent
                                            anchors.verticalCenter: parent.verticalCenter
                                            HoverHandler { id: artHov; cursorShape: Qt.PointingHandCursor }
                                            TapHandler { onTapped: Qt.openUrlExternally(modelData.url) }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.desc
                                        font.family: "Stack Sans Headline"
                                        font.pixelSize: 12
                                        color: theme.secondaryText
                                        wrapMode: Text.WordWrap
                                        leftPadding: 20
                                    }
                                }
                            }
                        }
                    }

                    // Card 3: Topologies & Export Targets
                    Rectangle {
                        width: parent.width
                        radius: 8
                        color: theme.surface
                        border.color: theme.borderColor
                        border.width: 1
                        clip: true

                        Column {
                            anchors { left: parent.left; right: parent.right; margins: 18 }
                            topPadding: 16
                            bottomPadding: 16
                            spacing: 12

                            Row {
                                spacing: 8
                                Codicon { icon: "symbol-parameter"; iconSize: 16; iconColor: theme.accent; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "Synthesis Topologies & Code Exporter Specifications"; font.family: "Stack Sans Headline"; font.pixelSize: 14; font.weight: Font.DemiBold; color: theme.primaryText; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Text {
                                width: parent.width
                                text: "Topologies:\n• Lowpass (LPF): Passband [0, Fc], N zeros placed at z = -1 (Nyquist).\n• Highpass (HPF): Passband [Fc, Fs/2], N zeros placed at z = +1 (DC cancellation).\n• Bandpass (BPF): Passband [Fc1, Fc2], N zeros at z = +1 and N zeros at z = -1.\n• Bandstop (Notch): Rejection [Fc1, Fc2], zeros placed on unit circle at e^(±jω0).\n\nExport Formats:\n• Embedded C: Direct Form II Transposed biquad function with state struct.\n• Modern C++20: Vectorized biquad class with constexpr coefficient arrays.\n• Python (SciPy): Standalone script with signal.sosfilt and matplotlib verification.\n• JSON Schema: Machine-readable specification and second-order sections."
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
}

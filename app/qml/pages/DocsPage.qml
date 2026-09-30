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
                // TAB 1: THEORY & MATHEMATICS
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.activeTab === 1

                    // Page Title (H1)
                    Text {
                        text: "Interactive DSP Theory Playground"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 26
                        font.weight: Font.Normal
                        color: theme.primaryText
                    }

                    // Intro paragraph with blue link
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "The core DSP synthesis engine in Overtune 3 is packed with classical continuous-to-discrete mathematical transformations. This page highlights a number of them and lets you interactively explore theoretical pole-zero mappings, pre-warped bilinear transforms, and biquadratic section cascades. For full mathematical derivations on the filter engine and more head over to our <a href='https://github.com/shadcy/overtune3' style='color:" + theme.accent + "; text-decoration:none;'>documentation</a>."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                    }

                    // Bullet list of features
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { title: "Butterworth Prototype", url: "https://en.wikipedia.org/wiki/Butterworth_filter", desc: "maximally flat passband response with zero ripple and monotonic 6N dB/octave attenuation." },
                                { title: "Chebyshev Type I", url: "https://en.wikipedia.org/wiki/Chebyshev_filter", desc: "minimizes peak Chebyshev error with equiripple passband behavior and steep transition bandwidth." },
                                { title: "Chebyshev Type II", url: "https://en.wikipedia.org/wiki/Chebyshev_filter#Type_II_Chebyshev_filters", desc: "maximally flat passband with finite transmission zeros placed along the imaginary axis in the stopband." },
                                { title: "Elliptic (Cauer)", url: "https://en.wikipedia.org/wiki/Elliptic_filter", desc: "Jacobian elliptic rational functions providing equiripple behavior in both bands and the sharpest transition." },
                                { title: "Bessel (Thomson)", url: "https://en.wikipedia.org/wiki/Bessel_filter", desc: "maximally flat group delay and linear phase response, preserving waveform pulses without transient ringing." },
                                { title: "Bilinear Transform", url: "https://en.wikipedia.org/wiki/Bilinear_transform", desc: "conformal mapping transforming analog prototypes to discrete-time transfer functions with frequency pre-warping." },
                                { title: "Second-Order Sections (SOS)", url: "https://en.wikipedia.org/wiki/Digital_biquad_filter", desc: "conjugate-pair root grouping into cascaded biquads to prevent numerical coefficient quantization errors." },
                                { title: "Group Delay & Phase Delay", url: "https://en.wikipedia.org/wiki/Group_delay_and_phase_delay", desc: "negative phase derivative highlighting transit distortion across critical frequency bands." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: "• &nbsp;<a href='" + modelData.url + "' style='color:" + theme.accent + "; text-decoration:none;'>" + modelData.title + "</a> <font color='" + (theme.isDark ? "#8E8E93" : "#6E6E73") + "'>- " + modelData.desc + "</font>"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.55
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                            }
                        }
                    }

                    // Section Title (H2)
                    Text {
                        text: "Bilinear Transform & Pre-Warping"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 20
                        font.weight: Font.Normal
                        color: theme.primaryText
                        topPadding: 12
                    }

                    // Section intro
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "The bilinear transform maps continuous frequencies &Omega; into discrete frequencies &omega; via trapezoidal integration. Because the digital frequency interval [0, &pi;] non-linearly compresses the infinite analog frequency axis, all critical cutoff frequencies are pre-warped. Try the following analytical transformations in the synthesis pipeline below:"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                    }

                    // Numbered list with inline badges
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { html: "1. Tangent Pre-Warping - calculate the analog prototype angular frequency using <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;&Omega; = 2&middot;Fs&middot;tan(&pi;&middot;Fc / Fs)&nbsp;</span> to cancel digital frequency warping distortion." },
                                { html: "2. Prototype S-Plane Substitution - replace Laplace operator <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;s = (2/T)&middot;(1 - z^-1)/(1 + z^-1)&nbsp;</span> to derive discrete transfer function <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;H(z)&nbsp;</span>." },
                                { html: "3. Conjugate Root Factorization - group roots into complex conjugate pairs <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;(p, p*)&nbsp;</span> to form cascading Second-Order Sections <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;SOS biquads&nbsp;</span>." },
                                { html: "4. Direct Form II Transposed Execution - compute output samples using <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;y[n] = &sum; b_k&middot;x[n-k] - &sum; a_k&middot;y[n-k]&nbsp;</span> with minimal state storage." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: modelData.html
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.6
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                            }
                        }
                    }

                    // Conclusion / Footnote text
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "That is the tip of the iceberg for digital filter mathematics. Have a look at the Frequency Analysis Suite and our handy pole-zero constellation guide for additional diagnostic views."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        topPadding: 4
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 2: STEP-BY-STEP TUTORIALS & WORKFLOW GUIDES
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.activeTab === 2

                    // Page Title (H1)
                    Text {
                        text: "Interactive Tutorials & Workflow Playground"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 26
                        font.weight: Font.Normal
                        color: theme.primaryText
                    }

                    // Intro paragraph
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "The tutorial studio in Overtune 3 is packed with step-by-step DSP recipes. This page highlights a number of them and lets you interactively explore filter design workflows, from rapid specification to bare-metal embedded deployment. For full details on custom presets and community guides head over to our <a href='https://github.com/shadcy/overtune3' style='color:" + theme.accent + "; text-decoration:none;'>documentation</a>."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                    }

                    // Bullet list of tutorials
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { title: "Studio Audio Lowpass", url: "https://en.wikipedia.org/wiki/Low-pass_filter", desc: "remove high-frequency tape hiss and air noise above 12 kHz from studio vocal recordings without phase smearing." },
                                { title: "50/60 Hz Ground Loop Notch", url: "https://en.wikipedia.org/wiki/Band-stop_filter", desc: "eliminate electrical mains interference using sharp unit-circle transmission zeros with mathematical infinite rejection." },
                                { title: "Voice Telephony Bandpass", url: "https://en.wikipedia.org/wiki/Band-pass_filter", desc: "300 Hz to 3.4 kHz ITU-T G.712 compliant speech bandpass filter rejecting out-of-band acoustic noise." },
                                { title: "Bare-Metal Firmware Deployment", url: "https://en.wikipedia.org/wiki/Digital_biquad_filter", desc: "integrate Direct Form II Transposed biquad loops into microcontrollers with deterministic cycles and zero heap allocation." },
                                { title: "ECG / EEG Biomedical Filter", url: "https://en.wikipedia.org/wiki/High-pass_filter", desc: "isolate physiological rhythms while rejecting baseline wander and electrode motion artifacts." },
                                { title: "Subwoofer Crossover Alignment", url: "https://en.wikipedia.org/wiki/Butterworth_filter", desc: "24 dB/octave Linkwitz-Riley acoustic crossover synthesis with matched phase summation at crossover frequency." },
                                { title: "Interactive Workflow Shortcuts", url: "https://github.com/shadcy/overtune3", desc: "leverage quick navigation keybindings and drag-to-tune canvas handles directly within the application." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: "• &nbsp;<a href='" + modelData.url + "' style='color:" + theme.accent + "; text-decoration:none;'>" + modelData.title + "</a> <font color='" + (theme.isDark ? "#8E8E93" : "#6E6E73") + "'>- " + modelData.desc + "</font>"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.55
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                            }
                        }
                    }

                    // Section Title (H2)
                    Text {
                        text: "Step-by-Step Filter Design Workflow"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 20
                        font.weight: Font.Normal
                        color: theme.primaryText
                        topPadding: 12
                    }

                    // Section intro
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "Synthesizing and deploying a filter involves four core steps across the application workspaces. Try the following actions in the workflow pipeline below:"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                    }

                    // Numbered list with inline badges
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { html: "1. Synthesize Topology - in Filter Designer Studio, select <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Lowpass (LPF)&nbsp;</span> topology and drag the cutoff line directly to <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;12,000 Hz&nbsp;</span>." },
                                { html: "2. Verify System Stability - press <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Ctrl+2&nbsp;</span> to open Analysis Suite and confirm all poles lie within <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;|z| &lt; 1&nbsp;</span>." },
                                { html: "3. Simulate Audio Playback - navigate to Simulation Studio using <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Ctrl+3&nbsp;</span> and audition filtered vs. raw audio with the real-time spectrum analyzer." },
                                { html: "4. Export Production Code - press <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Ctrl+4&nbsp;</span> and select <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Embedded C&nbsp;</span> or <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;Modern C++20&nbsp;</span> to copy deployment code." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: modelData.html
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.6
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                            }
                        }
                    }

                    // Conclusion / Footnote text
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "That is the tip of the iceberg for digital filter engineering workflows. Have a look at the workspace switcher and our handy keyboard shortcuts for additional actions."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        topPadding: 4
                    }
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 3: CONTRIBUTORS & WIKI REFERENCES
                // ═════════════════════════════════════════════════════════════════
                Column {
                    width: parent.width
                    spacing: 16
                    visible: root.activeTab === 3

                    // Page Title (H1)
                    Text {
                        text: "Contributors & DSP Knowledge Base"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 26
                        font.weight: Font.Normal
                        color: theme.primaryText
                    }

                    // Intro paragraph with blue link
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "The Overtune 3 open-source project is packed with community contributions and DSP reference literature. This page highlights key contributors, guidelines for extending the engine, and direct links to comprehensive articles on digital signal processing across our <a href='https://github.com/shadcy/overtune3' style='color:" + theme.accent + "; text-decoration:none;'>documentation</a>."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                    }

                    // Bullet list of Wikipedia reference articles
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { title: "Butterworth Filter", url: "https://en.wikipedia.org/wiki/Butterworth_filter", desc: "maximally flat magnitude response in passband with zero ripple and monotonic roll-off." },
                                { title: "Chebyshev Filter", url: "https://en.wikipedia.org/wiki/Chebyshev_filter", desc: "equiripple passband (Type I) or stopband (Type II) minimizing peak Chebyshev approximation error." },
                                { title: "Elliptic Filter", url: "https://en.wikipedia.org/wiki/Elliptic_filter", desc: "Jacobian elliptic rational functions achieving the sharpest transition rolloff for any given order." },
                                { title: "Bessel Filter", url: "https://en.wikipedia.org/wiki/Bessel_filter", desc: "maximally flat group delay and linear phase response, preserving waveform pulses without transient ringing." },
                                { title: "Bilinear Transform", url: "https://en.wikipedia.org/wiki/Bilinear_transform", desc: "conformal mapping transforming analog prototypes to discrete-time transfer functions with frequency pre-warping." },
                                { title: "Digital Biquad Filter", url: "https://en.wikipedia.org/wiki/Digital_biquad_filter", desc: "Second-Order Section Direct Form II Transposed topology with optimal numerical stability." },
                                { title: "Group Delay & Phase Delay", url: "https://en.wikipedia.org/wiki/Group_delay_and_phase_delay", desc: "time delay of frequency envelopes computed as the negative derivative of phase with respect to frequency." },
                                { title: "Z-Transform & Stability Analysis", url: "https://en.wikipedia.org/wiki/Z-transform", desc: "discrete-time complex plane mapping BIBO stability to the interior of the unit circle." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: "• &nbsp;<a href='" + modelData.url + "' style='color:" + theme.accent + "; text-decoration:none;'>" + modelData.title + "</a> <font color='" + (theme.isDark ? "#8E8E93" : "#6E6E73") + "'>- " + modelData.desc + "</font>"
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.55
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                            }
                        }
                    }

                    // Section Title (H2)
                    Text {
                        text: "Contributing to Overtune 3"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 20
                        font.weight: Font.Normal
                        color: theme.primaryText
                        topPadding: 12
                    }

                    // Section intro
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "We welcome contributions from digital signal processing researchers, audio engineers, embedded firmware developers, and UI designers. Try the following contribution actions in the repository below:"
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                    }

                    // Numbered list with inline badges
                    Column {
                        width: parent.width
                        spacing: 8
                        topPadding: 4
                        bottomPadding: 4

                        Repeater {
                            model: [
                                { html: "1. Fork & Clone - clone the repository from <a href='https://github.com/shadcy/overtune3' style='color:" + theme.accent + "; text-decoration:none;'>github.com/shadcy/overtune3</a> and create a feature branch using <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;git checkout -b feature/my-filter&nbsp;</span>." },
                                { html: "2. Implement Algorithms - add new prototype approximations or filter topologies into <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;dsp/src/&nbsp;</span> in modern pure C++20 with zero external dependencies." },
                                { html: "3. Build & Validate - execute <span style=\"background-color:' + (theme.isDark ? '#2D2D2D' : '#E5E7EB') + '; color:' + (theme.isDark ? '#E0E0E0' : '#1F2937') + '; font-family:monospace; font-size:11px;\">&nbsp;./build.sh&nbsp;</span> to compile both the pure DSP engine and Qt 6 presentation layer." },
                                { html: "4. Submit Pull Request - push your branch and open a pull request on <a href='https://github.com/shadcy/overtune3/issues' style='color:" + theme.accent + "; text-decoration:none;'>github.com/shadcy/overtune3/issues</a> for review." }
                            ]
                            delegate: Text {
                                width: parent.width
                                textFormat: Text.RichText
                                text: modelData.html
                                font.family: "Stack Sans Headline"
                                font.pixelSize: 13
                                lineHeight: 1.6
                                wrapMode: Text.WordWrap
                                leftPadding: 16
                                onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                            }
                        }
                    }

                    // Conclusion / Footnote text
                    Text {
                        width: parent.width
                        textFormat: Text.RichText
                        text: "That is the tip of the iceberg for community collaboration. Have a look at our <a href='https://github.com/shadcy/overtune3/issues' style='color:" + theme.accent + "; text-decoration:none;'>issue tracker</a> and contribution guide on GitHub for open tasks and discussions. Maintained by <a href='https://github.com/shadcy' style='color:" + theme.accent + "; text-decoration:none;'>shadcy</a> and open-source contributors."
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 13
                        lineHeight: 1.55
                        color: theme.secondaryText
                        wrapMode: Text.WordWrap
                        topPadding: 4
                        onLinkActivated: function(link) { Qt.openUrlExternally(link) }
                    }
                }
            }
        }
    }
}

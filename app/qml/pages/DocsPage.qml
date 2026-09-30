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

        // ── Consistent Tab Page Headline ──────────────────────────────────────
        Item {
            width: parent.width
            height: pageHeader.implicitHeight + 8
            PageHeader {
                id: pageHeader
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: root.pageMargin
                    rightMargin: root.pageMargin
                    topMargin: 8
                }
                title: "Documentation & Theory"
            }
        }


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
                // TAB 1: THEORY & MATHEMATICS (Compiled MIT-styled LaTeX PDF)
                // ═════════════════════════════════════════════════════════════════
                LatexDocViewer {
                    width: parent.width
                    visible: root.activeTab === 1
                    docTitle: "Digital Filter Theory & Mathematical Formulations"
                    docBaseName: "theory_and_math"
                    pageCount: 3
                    pdfFileName: "theory_and_math.pdf"
                    externalLinks: [
                        { title: "Butterworth Filter Theory", url: "https://en.wikipedia.org/wiki/Butterworth_filter", desc: "Maximally flat passband response with closed-form pole locations along circle of radius Ωc." },
                        { title: "Chebyshev Filters (Type I & II)", url: "https://en.wikipedia.org/wiki/Chebyshev_filter", desc: "Chebyshev polynomial minimizations for steep passband or stopband equiripple responses." },
                        { title: "Elliptic (Cauer) Rational Filters", url: "https://en.wikipedia.org/wiki/Elliptic_filter", desc: "Jacobian elliptic rational functions achieving maximum transition sharpness." },
                        { title: "Bessel-Thomson Linear Phase Filters", url: "https://en.wikipedia.org/wiki/Bessel_filter", desc: "Reverse Bessel polynomials providing maximally flat group delay and zero transient ringing." },
                        { title: "Bilinear Transform with Pre-Warping", url: "https://en.wikipedia.org/wiki/Bilinear_transform", desc: "Conformal continuous-to-discrete mapping with tangent frequency pre-warping." },
                        { title: "Digital Biquad Second-Order Sections (SOS)", url: "https://en.wikipedia.org/wiki/Digital_biquad_filter", desc: "Direct Form II Transposed difference equations and quantization noise mitigation." },
                        { title: "Overtune 3 Project Source Code", url: "https://github.com/shadcy/overtune3", desc: "Complete modern C++20 DSP implementation and Qt 6 desktop application sources." }
                    ]
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 2: STEP-BY-STEP TUTORIALS & WORKFLOW GUIDES (Compiled MIT-styled LaTeX PDF)
                // ═════════════════════════════════════════════════════════════════
                LatexDocViewer {
                    width: parent.width
                    visible: root.activeTab === 2
                    docTitle: "Step-by-Step DSP Implementation & Synthesis Guide"
                    docBaseName: "tutorials_and_guides"
                    pageCount: 3
                    pdfFileName: "tutorials_and_guides.pdf"
                    externalLinks: [
                        { title: "Audio Filter Design & Practical Equalization", url: "https://en.wikipedia.org/wiki/Audio_filter", desc: "Guide to crossover alignment, subsonic filtering, and perceptual shelving filters." },
                        { title: "Direct Form II Transposed Biquad Loops", url: "https://en.wikipedia.org/wiki/Digital_biquad_filter", desc: "Low-overhead sample execution loops suitable for ARM Cortex-M and real-time audio threads." },
                        { title: "Low-Pass & High-Pass Audio Applications", url: "https://en.wikipedia.org/wiki/Low-pass_filter", desc: "Anti-aliasing, band limiting, and rumble elimination techniques in audio engineering." },
                        { title: "Band-Pass & Notch Ground Loop Isolation", url: "https://en.wikipedia.org/wiki/Band-stop_filter", desc: "Placing transmission zeros directly on the unit circle to kill 50/60 Hz hum." },
                        { title: "Overtune 3 DSP Repository Guides", url: "https://github.com/shadcy/overtune3", desc: "Source walkthroughs, challenge benchmarks, and tutorial DSL examples." }
                    ]
                }

                // ═════════════════════════════════════════════════════════════════
                // TAB 3: CONTRIBUTORS & WIKI REFERENCES (Compiled MIT-styled LaTeX PDF)
                // ═════════════════════════════════════════════════════════════════
                LatexDocViewer {
                    width: parent.width
                    visible: root.activeTab === 3
                    docTitle: "Overtune 3: Architecture, Wiki & Contributor Guide"
                    docBaseName: "contributors_and_wiki"
                    pageCount: 2
                    pdfFileName: "contributors_and_wiki.pdf"
                    externalLinks: [
                        { title: "Overtune 3 GitHub Repository", url: "https://github.com/shadcy/overtune3", desc: "Core C++20 DSP engine, Qt 6 QML desktop GUI, and build automation." },
                        { title: "Overtune 3 Issue Tracker & Feature Requests", url: "https://github.com/shadcy/overtune3/issues", desc: "Report issues, propose new filter prototypes, and submit pull requests." },
                        { title: "Project Maintainer Profile (shadcy)", url: "https://github.com/shadcy", desc: "Open-source developer profile and contact details." },
                        { title: "SciPy Signal Processing Documentation", url: "https://docs.scipy.org/doc/scipy/reference/signal.html", desc: "Standard reference for IIR filter design functions and verification." },
                        { title: "Digital Signal Processing Overview (Wikipedia)", url: "https://en.wikipedia.org/wiki/Digital_signal_processing", desc: "Fundamental theory, discrete transforms, and sampling theorems." },
                        { title: "Digital Biquad Filter Topologies (Wikipedia)", url: "https://en.wikipedia.org/wiki/Biquad_filter", desc: "Comparison of Direct Form I, Direct Form II, and lattice structures." }
                    ]
                }
            }
        }
    }
}

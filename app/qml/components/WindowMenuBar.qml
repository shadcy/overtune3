import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// WindowMenuBar.qml — Native-styled VS Code window titlebar menu
Rectangle {
    id: root
    height: 36
    color: theme.isDark ? "#1E1E20" : "#F5F6F8"
    border.color: theme.borderColor
    border.width: 1
    z: 90

    property var rootWindow: null
    readonly property bool compact: width < 1000

    // Component for clean, styled MenuItems with shortcuts and checkmarks
    component StyledMenuItem: MenuItem {
        id: mi
        property string shortcutText: ""

        implicitHeight: 28
        padding: 0
        leftPadding: 8
        rightPadding: 8
        topPadding: 0
        bottomPadding: 0

        arrow: Item {
            implicitWidth: 0
            implicitHeight: 0
            visible: false
        }

        contentItem: RowLayout {
            spacing: 8

            // Checkmark indicator slot
            Item {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: mi.checkable

                Codicon {
                    anchors.centerIn: parent
                    icon: "check"
                    iconSize: 11
                    iconColor: theme.accent
                    visible: mi.checked
                }
            }

            Text {
                text: mi.text
                font.family: "Stack Sans Headline"
                font.pixelSize: 12
                font.weight: Font.Normal
                color: mi.highlighted ? theme.primaryText : (mi.enabled ? theme.primaryText : theme.secondaryText)
                Layout.fillWidth: true
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: mi.shortcutText
                font.family: "Stack Sans Headline"
                font.pixelSize: 11
                color: theme.secondaryText
                opacity: 0.75
                visible: mi.shortcutText !== ""
                verticalAlignment: Text.AlignVCenter
            }

            // Submenu chevron for items that open submenus
            Codicon {
                icon: "chevron-right"
                iconSize: 10
                iconColor: mi.highlighted ? theme.primaryText : theme.secondaryText
                visible: mi.subMenu !== null && mi.subMenu !== undefined
                Layout.alignment: Qt.AlignVCenter
            }
        }

        background: Rectangle {
            implicitHeight: 28
            color: mi.highlighted ? (theme.isDark ? "#2C2F36" : "#EBF0F7") : "transparent"
            radius: 5
        }

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
        }
    }

    // Component for styled Submenus
    component StyledMenu: Menu {
        padding: 5
        delegate: MenuItem {
            id: smDelegateItem
            implicitHeight: 28
            padding: 0
            leftPadding: 8
            rightPadding: 8
            topPadding: 0
            bottomPadding: 0

            arrow: Item {
                implicitWidth: 0
                implicitHeight: 0
                visible: false
            }

            contentItem: RowLayout {
                spacing: 8

                Item {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    visible: smDelegateItem.checkable

                    Codicon {
                        anchors.centerIn: parent
                        icon: "check"
                        iconSize: 11
                        iconColor: theme.accent
                        visible: smDelegateItem.checked
                    }
                }

                Text {
                    text: smDelegateItem.text
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    color: smDelegateItem.highlighted ? theme.primaryText : (smDelegateItem.enabled ? theme.primaryText : theme.secondaryText)
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                Codicon {
                    icon: "chevron-right"
                    iconSize: 10
                    iconColor: smDelegateItem.highlighted ? theme.primaryText : theme.secondaryText
                    visible: smDelegateItem.subMenu !== null && smDelegateItem.subMenu !== undefined
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            background: Rectangle {
                implicitHeight: 28
                color: smDelegateItem.highlighted ? (theme.isDark ? "#2C2F36" : "#EBF0F7") : "transparent"
                radius: 5
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }
        }

        background: Rectangle {
            implicitWidth: 260
            color: theme.isDark ? "#1E1F24" : "#FFFFFF"
            border.color: theme.isDark ? "#32353D" : "#D5D9E0"
            border.width: 1
            radius: 8
        }
    }

    // Left cluster: MenuBar
    Row {
        id: leftCluster
        anchors {
            left: parent.left
            leftMargin: 8
            right: rightCluster.left
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        height: parent.height

        Flickable {
            id: menuScroller
            width: Math.max(0, parent.width)
            height: parent.height
            contentWidth: mainMenuBar.width
            contentHeight: height
            clip: true
            interactive: contentWidth > width
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.horizontal: ScrollBar {
                policy: menuScroller.contentWidth > menuScroller.width ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
                height: 2
            }

            // The complete menu set remains reachable by horizontal scrolling when compressed.
            MenuBar {
                id: mainMenuBar
                width: Math.max(menuScroller.width, implicitWidth)
                height: menuScroller.height
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle { color: "transparent" }

                delegate: MenuBarItem {
                    id: mbi
                    implicitHeight: 28
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    contentItem: Text {
                        text: mbi.text
                        font.family: "Stack Sans Headline"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: mbi.highlighted ? theme.primaryText : (mbi.hovered ? theme.primaryText : (theme.isDark ? "#D0D3D8" : "#4B5563"))
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        implicitHeight: 28
                        color: mbi.highlighted ? (theme.isDark ? "#353840" : "#DDE1E8") : (mbi.hovered ? (theme.isDark ? "#2A2D33" : "#E6E9EE") : "transparent")
                        radius: 6
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    padding: 0
                    leftPadding: root.compact ? 8 : 11
                    rightPadding: root.compact ? 8 : 11
                    topPadding: 0
                    bottomPadding: 0

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }
                }

            // ── 1. FILE MENU ──────────────────────────────────────────────────────────
            StyledMenu {
                title: "File"

                StyledMenuItem {
                    text: "New Filter (Reset)"
                    shortcutText: "Ctrl+N"
                    onTriggered: rootWindow.doReset()
                }

                StyledMenuItem {
                    text: "Save Generated Code..."
                    shortcutText: "Ctrl+S"
                    onTriggered: rootWindow.doSave()
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Export Magnitude Plot (PNG)..."
                    onTriggered: {
                        if (designPage && designPage.freqPlot) {
                            designPage.freqPlot.exportPlotImage()
                        } else {
                            rootWindow.showNotification("Open Design Studio to export magnitude plot", false)
                        }
                    }
                }

                StyledMenuItem {
                    text: "Export Pole-Zero Diagram (PNG)..."
                    onTriggered: {
                        if (analysisPage && analysisPage.pzPlot) {
                            analysisPage.pzPlot.exportPlotImage()
                        } else {
                            rootWindow.showNotification("Open Analysis Suite to export pole-zero plot", false)
                        }
                    }
                }

                StyledMenuItem {
                    text: "Export Simulation Waveform (PNG)..."
                    onTriggered: {
                        if (simulationPage && simulationPage.signalPlot) {
                            simulationPage.signalPlot.exportPlotImage()
                        } else {
                            rootWindow.showNotification("Open Simulation Studio to export waveform", false)
                        }
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Copy Coefficients CSV to Clipboard"
                    onTriggered: {
                        exportModel.setFormat(7) // CSV format
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("Filter coefficients CSV copied to clipboard", false)
                    }
                }

                StyledMenuItem {
                    text: "Copy Coefficients JSON to Clipboard"
                    onTriggered: {
                        exportModel.setFormat(6) // JSON format
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("Filter coefficients JSON copied to clipboard", false)
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Exit Overtune"
                    shortcutText: "Ctrl+Q"
                    onTriggered: Qt.quit()
                }
            }

            // ── 2. EDIT MENU ──────────────────────────────────────────────────────────
            StyledMenu {
                title: "Edit"

                StyledMenuItem {
                    text: "Copy C++ Biquad Class"
                    onTriggered: {
                        exportModel.setFormat(0)
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("C++ Biquad code copied to clipboard", false)
                    }
                }

                StyledMenuItem {
                    text: "Copy Python (SciPy) Script"
                    onTriggered: {
                        exportModel.setFormat(2)
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("Python (SciPy) filter script copied", false)
                    }
                }

                StyledMenuItem {
                    text: "Copy MATLAB Filter Script"
                    onTriggered: {
                        exportModel.setFormat(3)
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("MATLAB filter design script copied", false)
                    }
                }

                StyledMenuItem {
                    text: "Copy Rust Filter Implementation"
                    onTriggered: {
                        exportModel.setFormat(4)
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("Rust DSP filter implementation copied", false)
                    }
                }

                StyledMenuItem {
                    text: "Copy WebAudio (JS) Biquad Node"
                    onTriggered: {
                        exportModel.setFormat(5)
                        exportModel.generate(filterEngine)
                        exportModel.copyToClipboard()
                        rootWindow.showNotification("WebAudio JavaScript code copied", false)
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Copy Active Graph Image"
                    onTriggered: {
                        if (sidebar.currentPage === 0 && designPage && designPage.freqPlot) {
                            designPage.freqPlot.copyPlotImage()
                        } else if (sidebar.currentPage === 2 && simulationPage && simulationPage.signalPlot) {
                            simulationPage.signalPlot.copyPlotImage()
                        } else {
                            rootWindow.showNotification("Select Design or Simulation to copy plot image", false)
                        }
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Clear Simulation Waveforms"
                    shortcutText: "Ctrl+K"
                    onTriggered: rootWindow.doClear()
                }

                StyledMenuItem {
                    text: "Reset Filter to Default"
                    shortcutText: "Ctrl+R"
                    onTriggered: rootWindow.doReset()
                }
            }

            // ── 3. SELECTION MENU (Filter Specifications) ─────────────────────────────
            StyledMenu {
                title: "Selection"

                StyledMenu {
                    title: "Filter Topology / Family"

                    StyledMenuItem {
                        text: "Butterworth (Maximally Flat)"
                        checkable: true
                        checked: filterEngine.filterResponse === 0
                        onTriggered: { filterEngine.filterResponse = 0; filterEngine.design(); rootWindow.showNotification("Selected: Butterworth (Maximally Flat)", false) }
                    }
                    StyledMenuItem {
                        text: "Chebyshev Type I (Passband Ripple)"
                        checkable: true
                        checked: filterEngine.filterResponse === 1
                        onTriggered: { filterEngine.filterResponse = 1; filterEngine.design(); rootWindow.showNotification("Selected: Chebyshev Type I", false) }
                    }
                    StyledMenuItem {
                        text: "Chebyshev Type II (Stopband Ripple)"
                        checkable: true
                        checked: filterEngine.filterResponse === 2
                        onTriggered: { filterEngine.filterResponse = 2; filterEngine.design(); rootWindow.showNotification("Selected: Chebyshev Type II", false) }
                    }
                    StyledMenuItem {
                        text: "Elliptic / Cauer (Equiripple)"
                        checkable: true
                        checked: filterEngine.filterResponse === 3
                        onTriggered: { filterEngine.filterResponse = 3; filterEngine.design(); rootWindow.showNotification("Selected: Elliptic (Cauer)", false) }
                    }
                    StyledMenuItem {
                        text: "Bessel / Thomson (Linear Phase)"
                        checkable: true
                        checked: filterEngine.filterResponse === 4
                        onTriggered: { filterEngine.filterResponse = 4; filterEngine.design(); rootWindow.showNotification("Selected: Bessel (Linear Phase)", false) }
                    }
                }

                StyledMenu {
                    title: "Filter Response Type"

                    StyledMenuItem {
                        text: "Low Pass (LPF)"
                        checkable: true
                        checked: filterEngine.filterType === 0
                        onTriggered: { filterEngine.filterType = 0; filterEngine.design(); rootWindow.showNotification("Response: Low Pass", false) }
                    }
                    StyledMenuItem {
                        text: "High Pass (HPF)"
                        checkable: true
                        checked: filterEngine.filterType === 1
                        onTriggered: { filterEngine.filterType = 1; filterEngine.design(); rootWindow.showNotification("Response: High Pass", false) }
                    }
                    StyledMenuItem {
                        text: "Band Pass (BPF)"
                        checkable: true
                        checked: filterEngine.filterType === 2
                        onTriggered: { filterEngine.filterType = 2; filterEngine.design(); rootWindow.showNotification("Response: Band Pass", false) }
                    }
                    StyledMenuItem {
                        text: "Band Stop / Notch (BSF)"
                        checkable: true
                        checked: filterEngine.filterType === 3
                        onTriggered: { filterEngine.filterType = 3; filterEngine.design(); rootWindow.showNotification("Response: Band Stop", false) }
                    }
                }

                StyledMenu {
                    title: "Filter Order"

                    StyledMenuItem {
                        text: "2nd Order (Single Biquad)"
                        checkable: true
                        checked: filterEngine.order === 2
                        onTriggered: { filterEngine.order = 2; filterEngine.design(); rootWindow.showNotification("Order set to 2", false) }
                    }
                    StyledMenuItem {
                        text: "4th Order (2 Biquads)"
                        checkable: true
                        checked: filterEngine.order === 4
                        onTriggered: { filterEngine.order = 4; filterEngine.design(); rootWindow.showNotification("Order set to 4", false) }
                    }
                    StyledMenuItem {
                        text: "6th Order (3 Biquads)"
                        checkable: true
                        checked: filterEngine.order === 6
                        onTriggered: { filterEngine.order = 6; filterEngine.design(); rootWindow.showNotification("Order set to 6", false) }
                    }
                    StyledMenuItem {
                        text: "8th Order (4 Biquads)"
                        checkable: true
                        checked: filterEngine.order === 8
                        onTriggered: { filterEngine.order = 8; filterEngine.design(); rootWindow.showNotification("Order set to 8", false) }
                    }
                    StyledMenuItem {
                        text: "10th Order (5 Biquads)"
                        checkable: true
                        checked: filterEngine.order === 10
                        onTriggered: { filterEngine.order = 10; filterEngine.design(); rootWindow.showNotification("Order set to 10", false) }
                    }
                }

                StyledMenu {
                    title: "Audio Sampling Rate"

                    StyledMenuItem {
                        text: "44,100 Hz (CD Audio)"
                        checkable: true
                        checked: filterEngine.sampleRate === 44100
                        onTriggered: { filterEngine.sampleRate = 44100; filterEngine.design(); rootWindow.showNotification("Sample Rate: 44.1 kHz", false) }
                    }
                    StyledMenuItem {
                        text: "48,000 Hz (Standard Production)"
                        checkable: true
                        checked: filterEngine.sampleRate === 48000
                        onTriggered: { filterEngine.sampleRate = 48000; filterEngine.design(); rootWindow.showNotification("Sample Rate: 48 kHz", false) }
                    }
                    StyledMenuItem {
                        text: "96,000 Hz (Hi-Res Audio)"
                        checkable: true
                        checked: filterEngine.sampleRate === 96000
                        onTriggered: { filterEngine.sampleRate = 96000; filterEngine.design(); rootWindow.showNotification("Sample Rate: 96 kHz", false) }
                    }
                    StyledMenuItem {
                        text: "192,000 Hz (Studio Master)"
                        checkable: true
                        checked: filterEngine.sampleRate === 192000
                        onTriggered: { filterEngine.sampleRate = 192000; filterEngine.design(); rootWindow.showNotification("Sample Rate: 192 kHz", false) }
                    }
                }
            }

            // ── 4. VIEW MENU (Zoom, Scale, Desmos, Overlays) ──────────────────────────
            StyledMenu {
                title: "View"

                StyledMenuItem {
                    text: "Auto Scale / Fit View (Desmos)"
                    shortcutText: "Ctrl+0"
                    onTriggered: rootWindow.doAutoScale()
                }

                StyledMenuItem {
                    text: "Zoom In (+)"
                    shortcutText: "Ctrl+="
                    onTriggered: rootWindow.doZoomIn()
                }

                StyledMenuItem {
                    text: "Zoom Out (−)"
                    shortcutText: "Ctrl+-"
                    onTriggered: rootWindow.doZoomOut()
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "DSP Specification Guides"
                    checkable: true
                    checked: designPage && designPage.freqPlot ? designPage.freqPlot.showDspGuides : false
                    onTriggered: {
                        if (designPage && designPage.freqPlot) {
                            designPage.freqPlot.showDspGuides = !designPage.freqPlot.showDspGuides
                            rootWindow.showNotification("DSP Guides: " + (designPage.freqPlot.showDspGuides ? "ON" : "OFF"), false)
                        }
                    }
                }

                StyledMenuItem {
                    text: "Data Cursor / Inspector (+)"
                    checkable: true
                    checked: designPage && designPage.freqPlot ? designPage.freqPlot.showCrosshair : false
                    onTriggered: {
                        if (designPage && designPage.freqPlot) {
                            designPage.freqPlot.showCrosshair = !designPage.freqPlot.showCrosshair
                            rootWindow.showNotification("Data Cursor (+): " + (designPage.freqPlot.showCrosshair ? "ON" : "OFF"), false)
                        }
                    }
                }

                StyledMenuItem {
                    text: "Polar Grid on Z-Plane"
                    checkable: true
                    checked: analysisPage && analysisPage.pzPlot ? analysisPage.pzPlot.showPolarGrid : true
                    onTriggered: {
                        if (analysisPage && analysisPage.pzPlot) {
                            analysisPage.pzPlot.showPolarGrid = !analysisPage.pzPlot.showPolarGrid
                            analysisPage.pzPlot.schedulePaint()
                        }
                    }
                }

                StyledMenuItem {
                    text: "Unit Circle Stability Shading"
                    checkable: true
                    checked: analysisPage && analysisPage.pzPlot ? analysisPage.pzPlot.showStabilityRegion : true
                    onTriggered: {
                        if (analysisPage && analysisPage.pzPlot) {
                            analysisPage.pzPlot.showStabilityRegion = !analysisPage.pzPlot.showStabilityRegion
                            analysisPage.pzPlot.schedulePaint()
                        }
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Toggle Dark / Light Theme"
                    shortcutText: "Ctrl+T"
                    onTriggered: {
                        theme.themeMode = theme.isDark ? 1 : 2
                        rootWindow.showNotification("Theme set to " + (theme.isDark ? "Dark" : "Light"), false)
                    }
                }

                StyledMenuItem {
                    text: "Toggle Fullscreen"
                    shortcutText: "F11"
                    onTriggered: {
                        if (rootWindow.visibility === Window.FullScreen) {
                            rootWindow.visibility = Window.Windowed
                        } else {
                            rootWindow.visibility = Window.FullScreen
                        }
                    }
                }
            }

            // ── 5. GO MENU (Workspace Navigation) ─────────────────────────────────────
            StyledMenu {
                title: "Go"

                StyledMenuItem {
                    text: "Filter Design Studio"
                    shortcutText: "Ctrl+1"
                    onTriggered: { rootWindow.navigateTo(0); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Frequency Analysis Suite"
                    shortcutText: "Ctrl+2"
                    onTriggered: { rootWindow.navigateTo(1); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Signal Simulation Studio"
                    shortcutText: "Ctrl+3"
                    onTriggered: { rootWindow.navigateTo(2); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Production Code Exporter"
                    shortcutText: "Ctrl+4"
                    onTriggered: { rootWindow.navigateTo(3); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Theory & Documentation"
                    shortcutText: "Ctrl+5"
                    onTriggered: { rootWindow.navigateTo(4); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Omi"
                    shortcutText: "Ctrl+6"
                    onTriggered: { rootWindow.navigateTo(5); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "Workspace Settings"
                    shortcutText: "Ctrl+7"
                    onTriggered: { rootWindow.navigateTo(6); rootWindow.showTabName(); }
                }

                StyledMenuItem {
                    text: "DSP Window Function Studio..."
                    onTriggered: {
                        if (rootWindow && typeof rootWindow.openWindowingStudio === "function") {
                            rootWindow.openWindowingStudio()
                        }
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Next Workspace Tab"
                    shortcutText: "Ctrl+Tab"
                    onTriggered: rootWindow.nextTab()
                }

                StyledMenuItem {
                    text: "Previous Workspace Tab"
                    shortcutText: "Ctrl+Shift+Tab"
                    onTriggered: rootWindow.prevTab()
                }
            }

            // ── 6. RUN MENU (Live DSP Signal Simulation) ──────────────────────────────
            StyledMenu {
                title: "Run"

                StyledMenuItem {
                    text: "Run Filter Simulation (Animated)"
                    shortcutText: "F5"
                    onTriggered: {
                        simulation.applyFilter(filterEngine)
                        if (simulationPage && simulationPage.signalPlot) {
                            simulationPage.signalPlot.restartAnimation()
                        }
                        rootWindow.showNotification("Simulating filter response in realtime...", false)
                    }
                }

                StyledMenuItem {
                    text: "Replay Realtime Filter Animation"
                    onTriggered: {
                        if (sidebar.currentPage !== 2) rootWindow.navigateTo(2)
                        if (simulationPage && simulationPage.signalPlot) {
                            simulationPage.signalPlot.restartAnimation()
                        }
                    }
                }

                StyledMenuItem {
                    text: "Continuous Loop Sweep (Oscilloscope)"
                    checkable: true
                    checked: simulationPage && simulationPage.signalPlot ? simulationPage.signalPlot.loopAnimation : false
                    onTriggered: {
                        if (simulationPage && simulationPage.signalPlot) {
                            simulationPage.signalPlot.loopAnimation = !simulationPage.signalPlot.loopAnimation
                            if (simulationPage.signalPlot.loopAnimation) {
                                simulationPage.signalPlot.restartAnimation()
                            }
                            rootWindow.showNotification(simulationPage.signalPlot.loopAnimation ? "Loop sweep active" : "Loop sweep disabled", false)
                        }
                    }
                }

                MenuSeparator {}

                StyledMenu {
                    title: "Signal Generator Presets"

                    StyledMenuItem {
                        text: "Sine Wave (1 kHz)"
                        onTriggered: {
                            simulation.generateSine(1000, filterEngine.sampleRate, 0.04)
                            simulation.applyFilter(filterEngine)
                            rootWindow.navigateTo(2)
                            if (simulationPage && simulationPage.signalPlot) simulationPage.signalPlot.restartAnimation()
                            rootWindow.showNotification("Generated: Sine Wave @ 1 kHz", false)
                        }
                    }

                    StyledMenuItem {
                        text: "Chirp Sweep (20 Hz - 20 kHz)"
                        onTriggered: {
                            simulation.generateChirp(20, Math.min(20000, filterEngine.sampleRate * 0.45), filterEngine.sampleRate, 0.05)
                            simulation.applyFilter(filterEngine)
                            rootWindow.navigateTo(2)
                            if (simulationPage && simulationPage.signalPlot) simulationPage.signalPlot.restartAnimation()
                            rootWindow.showNotification("Generated: Logarithmic Chirp Sweep", false)
                        }
                    }

                    StyledMenuItem {
                        text: "Dual-Tone Intermodulation"
                        onTriggered: {
                            const f1 = Math.min(1000, Math.max(100, filterEngine.cutoffFreq * 0.5))
                            const f2 = Math.max(3000, Math.min(18000, filterEngine.cutoffFreq * 1.5))
                            simulation.generateMultiTone(f1, f2, filterEngine.sampleRate, 0.04)
                            simulation.applyFilter(filterEngine)
                            rootWindow.navigateTo(2)
                            if (simulationPage && simulationPage.signalPlot) simulationPage.signalPlot.restartAnimation()
                            rootWindow.showNotification("Generated: Dual-Tone (" + Math.round(f1) + " Hz / " + Math.round(f2) + " Hz)", false)
                        }
                    }

                    StyledMenuItem {
                        text: "White Gaussian Noise"
                        onTriggered: {
                            simulation.generateNoise(0.04, filterEngine.sampleRate)
                            simulation.applyFilter(filterEngine)
                            rootWindow.navigateTo(2)
                            if (simulationPage && simulationPage.signalPlot) simulationPage.signalPlot.restartAnimation()
                            rootWindow.showNotification("Generated: White Gaussian Noise", false)
                        }
                    }

                    StyledMenuItem {
                        text: "Square Wave (1 kHz)"
                        onTriggered: {
                            simulation.generateSquare(1000, filterEngine.sampleRate, 0.04)
                            simulation.applyFilter(filterEngine)
                            rootWindow.navigateTo(2)
                            if (simulationPage && simulationPage.signalPlot) simulationPage.signalPlot.restartAnimation()
                            rootWindow.showNotification("Generated: 1 kHz Square Wave", false)
                        }
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "Clear Simulation Buffer"
                    shortcutText: "Ctrl+K"
                    onTriggered: rootWindow.doClear()
                }
            }

            // ── 7. PLOT MENU (DSP Display Configurations) ─────────────────────────────
            StyledMenu {
                title: "Plot"

                StyledMenu {
                    title: "Frequency Response Mode"

                    StyledMenuItem {
                        text: "Magnitude (dB)"
                        shortcutText: "Alt+1"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? (designPage.freqPlot.displayMode === 0 && designPage.freqPlot.magScaleMode === 0) : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.displayMode = 0
                                designPage.freqPlot.magScaleMode = 0
                                designPage.freqPlot.refreshPoints()
                                designPage.freqPlot.schedulePaint()
                                rootWindow.showNotification("Plot Mode: Magnitude (dB)", false)
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Magnitude (Linear |H|)"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? (designPage.freqPlot.displayMode === 0 && designPage.freqPlot.magScaleMode === 1) : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.displayMode = 0
                                designPage.freqPlot.magScaleMode = 1
                                designPage.freqPlot.refreshPoints()
                                designPage.freqPlot.schedulePaint()
                                rootWindow.showNotification("Plot Mode: Linear Magnitude |H|", false)
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Phase Response (°)"
                        shortcutText: "Alt+2"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? (designPage.freqPlot.displayMode === 1 && designPage.freqPlot.phaseWrapMode === 0) : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.displayMode = 1
                                designPage.freqPlot.phaseWrapMode = 0
                                designPage.freqPlot.refreshPoints()
                                designPage.freqPlot.schedulePaint()
                                rootWindow.showNotification("Plot Mode: Phase (Unwrapped)", false)
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Phase Wrapped [-180°, 180°]"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? (designPage.freqPlot.displayMode === 1 && designPage.freqPlot.phaseWrapMode === 1) : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.displayMode = 1
                                designPage.freqPlot.phaseWrapMode = 1
                                designPage.freqPlot.refreshPoints()
                                designPage.freqPlot.schedulePaint()
                                rootWindow.showNotification("Plot Mode: Phase (Wrapped)", false)
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Group Delay (samples)"
                        shortcutText: "Alt+3"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? (designPage.freqPlot.displayMode === 2) : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.displayMode = 2
                                designPage.freqPlot.refreshPoints()
                                designPage.freqPlot.schedulePaint()
                                rootWindow.showNotification("Plot Mode: Group Delay", false)
                            }
                        }
                    }
                }

                StyledMenu {
                    title: "Frequency Axis Scale"

                    StyledMenuItem {
                        text: "Logarithmic (Hz)"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? designPage.freqPlot.freqScale === 0 : true
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.freqScale = 0
                                designPage.freqPlot.autoScale()
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Linear (Hz)"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? designPage.freqPlot.freqScale === 1 : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.freqScale = 1
                                designPage.freqPlot.autoScale()
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Normalized Radian (ω/π)"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? designPage.freqPlot.freqScale === 2 : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.freqScale = 2
                                designPage.freqPlot.autoScale()
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Normalized Digital (f/fs)"
                        checkable: true
                        checked: designPage && designPage.freqPlot ? designPage.freqPlot.freqScale === 3 : false
                        onTriggered: {
                            if (designPage && designPage.freqPlot) {
                                designPage.freqPlot.freqScale = 3
                                designPage.freqPlot.autoScale()
                            }
                        }
                    }
                }

                StyledMenu {
                    title: "Simulation Waveform Style"

                    StyledMenuItem {
                        text: "Continuous Curve"
                        checkable: true
                        checked: simulationPage && simulationPage.signalPlot ? simulationPage.signalPlot.displayStyle === 0 : true
                        onTriggered: {
                            if (simulationPage && simulationPage.signalPlot) {
                                simulationPage.signalPlot.displayStyle = 0
                                simulationPage.signalPlot.schedulePaint()
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Discrete Stem (Digital)"
                        checkable: true
                        checked: simulationPage && simulationPage.signalPlot ? simulationPage.signalPlot.displayStyle === 1 : false
                        onTriggered: {
                            if (simulationPage && simulationPage.signalPlot) {
                                simulationPage.signalPlot.displayStyle = 1
                                simulationPage.signalPlot.schedulePaint()
                            }
                        }
                    }

                    StyledMenuItem {
                        text: "Sample Points Only"
                        checkable: true
                        checked: simulationPage && simulationPage.signalPlot ? simulationPage.signalPlot.displayStyle === 2 : false
                        onTriggered: {
                            if (simulationPage && simulationPage.signalPlot) {
                                simulationPage.signalPlot.displayStyle = 2
                                simulationPage.signalPlot.schedulePaint()
                            }
                        }
                    }
                }
            }

            // ── 8. HELP MENU ──────────────────────────────────────────────────────────
            StyledMenu {
                title: "Help"

                StyledMenuItem {
                    text: "Interactive Challenges & Lab"
                    onTriggered: { rootWindow.navigateTo(4); rootWindow.showNotification("Opened Interactive Challenges & Theory", false) }
                }

                StyledMenuItem {
                    text: "Filter Theory & Mathematics"
                    onTriggered: { rootWindow.navigateTo(4); rootWindow.showNotification("Opened DSP Filter Theory Documentation", false) }
                }

                StyledMenuItem {
                    text: "Keyboard Shortcuts Guide"
                    onTriggered: {
                        rootWindow.showNotification("Shortcuts: Ctrl+1..6 (Tabs), Ctrl+S (Save), Ctrl+R (Reset), F5 (Run), Ctrl+0 (Fit)", false)
                    }
                }

                MenuSeparator {}

                StyledMenuItem {
                    text: "What's New in Overtune 3"
                    onTriggered: {
                        if (typeof rootWindow.showWhatsNew === "function") {
                            rootWindow.showWhatsNew()
                        }
                    }
                }

                StyledMenuItem {
                    text: "Check for Updates..."
                    shortcutText: updateInstaller.hasUpdate ? ("v" + updateInstaller.latestVersion) : ""
                    onTriggered: {
                        if (rootWindow && typeof rootWindow.checkUpdatesNow === "function") {
                            rootWindow.checkUpdatesNow()
                        }
                    }
                }

                StyledMenuItem {
                    text: "System Installer & Shortcuts..."
                    onTriggered: {
                        if (rootWindow && typeof rootWindow.showInstallerUpdater === "function") {
                            rootWindow.showInstallerUpdater(1)
                        }
                    }
                }

                StyledMenuItem {
                    text: "About Overtune 3 DSP Filter Designer"
                    onTriggered: {
                        rootWindow.showNotification("Overtune 3 — Professional Digital Filter Design & Live Simulation Studio", false)
                    }
                }
            }
            }
        }
    }

    // Right cluster: Auto-Scale Quick Button + Theme Switcher
    Row {
        id: rightCluster
        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }
        spacing: 6

        // Update Quick Button (Only shown when an update is available)
        Rectangle {
            id: updateBtn
            visible: updateInstaller.hasUpdate
            width: root.compact ? 26 : updateRow.implicitWidth + 16
            height: 26
            implicitWidth: updateRow.implicitWidth + 16
            radius: 6
            color: updateMouse.containsMouse ? (theme.isDark ? "#32353A" : "#E2E5E9") : Qt.darker(theme.accent, 1.3)
            border.color: theme.accent
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                id: updateRow
                anchors.centerIn: parent
                spacing: 5

                Codicon {
                    icon: updateInstaller.hasUpdate ? "cloud-download" : "package"
                    iconSize: 12
                    iconColor: updateInstaller.hasUpdate ? theme.accent : theme.secondaryText
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: updateInstaller.hasUpdate ? "Update Ready" : "Installer"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: updateInstaller.hasUpdate ? "#FFFFFF" : theme.secondaryText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.compact
                }
            }

            CustomToolTip {
                visible: updateMouse.containsMouse
                text: updateInstaller.hasUpdate ? "Update v" + updateInstaller.latestVersion + " is available!" : "Open Installer & Update Manager"
            }

            MouseArea {
                id: updateMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (rootWindow && typeof rootWindow.showInstallerUpdater === "function") {
                        rootWindow.showInstallerUpdater(updateInstaller.hasUpdate ? 0 : 1)
                    }
                }
            }
        }

        // Accent-colored squircle "What's New" button
        Rectangle {
            id: whatsNewBtn
            width: root.compact ? 26 : whatsNewRow.implicitWidth + 16
            height: 26
            implicitWidth: whatsNewRow.implicitWidth + 16
            radius: 6
            color: whatsNewMouse.containsMouse ? Qt.darker(theme.accent, 1.15) : theme.accent
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 120 } }

            Row {
                id: whatsNewRow
                anchors.centerIn: parent
                spacing: 5

                Codicon {
                    icon: "info"
                    iconSize: 12
                    iconColor: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "What's New"
                    font.family: "Stack Sans Headline"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.compact
                }
            }

            CustomToolTip {
                visible: whatsNewMouse.containsMouse
                text: "See What's New in Overtune 3"
            }

            MouseArea {
                id: whatsNewMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (rootWindow && typeof rootWindow.showWhatsNew === "function") {
                        rootWindow.showWhatsNew()
                    }
                }
            }
        }

        // Auto Scale / Fit View quick button
        Rectangle {
            width: 28
            height: 26
            radius: 6
            Accessible.role: Accessible.Button
            Accessible.name: "Auto scale plot"
            color: fitTopMouse.containsMouse ? (theme.isDark ? "#32353A" : "#E2E5E9") : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Codicon {
                anchors.centerIn: parent
                icon: "screen-full"
                iconSize: 13
                iconColor: fitTopMouse.containsMouse ? theme.primaryText : theme.secondaryText
            }

            CustomToolTip {
                visible: fitTopMouse.containsMouse
                text: "Auto Scale / Fit View (Ctrl+0)"
            }

            MouseArea {
                id: fitTopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: rootWindow.doAutoScale()
            }
        }

        // Quick Theme Toggle Button
        Rectangle {
            width: 28
            height: 26
            radius: 6
            Accessible.role: Accessible.Button
            Accessible.name: "Toggle color theme"
            color: themeTopMouse.containsMouse ? (theme.isDark ? "#32353A" : "#E2E5E9") : "transparent"
            anchors.verticalCenter: parent.verticalCenter

            Codicon {
                anchors.centerIn: parent
                icon: theme.isDark ? "sun" : "color-mode"
                iconSize: 13
                iconColor: themeTopMouse.containsMouse ? theme.primaryText : theme.secondaryText
            }

            CustomToolTip {
                visible: themeTopMouse.containsMouse
                text: "Switch to " + (theme.isDark ? "Light" : "Dark") + " Theme (Ctrl+T)"
            }

            MouseArea {
                id: themeTopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    theme.themeMode = theme.isDark ? 1 : 2
                    rootWindow.showNotification("Theme switched to " + (theme.isDark ? "Dark" : "Light"), false)
                }
            }
        }
    }
}

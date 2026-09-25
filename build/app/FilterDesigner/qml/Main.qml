import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"
import "pages"

// Main.qml — Root application window
Window {
    id: root
    title:         "Overtune 3"
    width:         1280
    height:        800
    minimumWidth:  420
    minimumHeight: 360
    visible:       true
    color:         theme.background

    readonly property bool isNarrow: width < 820
    readonly property bool isCompact: width < 1100
    readonly property int contentMargin: isNarrow ? 12 : 20

    // ── Bundled fonts (Inter OFL, Codicons CC-BY 4.0) ──────────────────────────
    FontLoader { id: interRegular;  source: "qrc:/FilterDesigner/fonts/Inter-Regular.ttf" }
    FontLoader { id: interMedium;   source: "qrc:/FilterDesigner/fonts/Inter-Medium.ttf" }
    FontLoader { id: interSemiBold; source: "qrc:/FilterDesigner/fonts/Inter-SemiBold.ttf" }
    FontLoader { id: interBold;     source: "qrc:/FilterDesigner/fonts/Inter-Bold.ttf" }
    FontLoader { id: codiconFont;   source: "qrc:/FilterDesigner/fonts/codicon.ttf" }

    readonly property bool fontsReady:
        interRegular.status === FontLoader.Ready &&
        codiconFont.status === FontLoader.Ready

    function navigateTo(pageIndex) {
        const n = Math.max(0, Math.min(5, pageIndex | 0))
        if (sidebar.currentPage !== n)
            sidebar.currentPage = n
    }

    // ── Error snackbar ────────────────────────────────────────────────────────
    Rectangle {
        id: errorBar
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 24
            leftMargin: 16
            rightMargin: 16
        }
        width: Math.min(parent.width - 32, Math.max(160, errorText.implicitWidth + 32))
        height: 40
        radius: 10
        color: theme.danger
        opacity: 0
        z: 100
        clip: true

        Text {
            id: errorText
            anchors.centerIn: parent
            width: parent.width - 24
            color: "#FFFFFF"
            font.family: "Inter"
            font.pixelSize: 13
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }

        Timer {
            id: errorHideTimer
            interval: 4000
            onTriggered: errorBar.opacity = 0
        }
    }

    Connections {
        target: filterEngine
        function onErrorOccurred(msg) {
            errorText.text = msg
            errorBar.opacity = 1
            errorHideTimer.restart()
        }
    }

    // ── Main layout ───────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent
        // Avoid painting before fonts register (prevents glyph flash)
        opacity: root.fontsReady ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Sidebar {
            id: sidebar
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
            }
            width: 48

            onCurrentPageChanged: {
                pageStack.currentIndex = currentPage
                if (currentPage === 3)
                    exportModel.generate(filterEngine)
            }
        }

        Item {
            id: contentHost
            anchors {
                top: parent.top
                left: sidebar.right
                right: parent.right
                bottom: parent.bottom
            }
            clip: true

            StackLayout {
                id: pageStack
                anchors.fill: parent
                currentIndex: 0

                DesignPage     { Layout.fillWidth: true; Layout.fillHeight: true }
                AnalysisPage   { Layout.fillWidth: true; Layout.fillHeight: true }
                SimulationPage { Layout.fillWidth: true; Layout.fillHeight: true }
                ExportPage     { Layout.fillWidth: true; Layout.fillHeight: true }
                DocsPage       { Layout.fillWidth: true; Layout.fillHeight: true }
                SettingsPage   { Layout.fillWidth: true; Layout.fillHeight: true }
            }
        }
    }

    Behavior on color { ColorAnimation { duration: 300 } }
}

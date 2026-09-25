import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

// SimulationPage.qml — overflow-safe toolbar + plot
Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitWidth: 800
    implicitHeight: 600
    clip: true

    readonly property int pageMargin: width < 700 ? 10 : 16

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.pageMargin
        spacing: 10

        Text {
            text: "Simulation"
            font.family: "Stack Sans Headline"
            font.pixelSize: 18
            font.weight: Font.DemiBold
            color: theme.primaryText
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            contentWidth: toolRow.implicitWidth
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentWidth > width

            Row {
                id: toolRow
                spacing: 8
                StyledButton { text: "Load WAV"; primary: false; implicitWidth: 88; onClicked: wavDialog.open() }
                StyledButton { text: "Load CSV"; primary: false; implicitWidth: 88; onClicked: csvDialog.open() }
                StyledButton { text: "Sine"; primary: false; implicitWidth: 56; onClicked: simulation.generateSine(440, filterEngine.sampleRate, 0.1) }
                StyledButton {
                    text: "Chirp"; primary: false; implicitWidth: 56
                    onClicked: simulation.generateChirp(100, filterEngine.sampleRate / 2 * 0.9, filterEngine.sampleRate, 0.1)
                }
                StyledButton {
                    text: "Apply Filter"; primary: true; implicitWidth: 104
                    enabled: simulation.hasData
                    onClicked: simulation.applyFilter(filterEngine)
                }
                StyledButton { text: "Clear"; primary: false; implicitWidth: 64; onClicked: simulation.clear() }
            }
        }

        Text {
            Layout.fillWidth: true
            text: simulation.hasData ? simulation.signalLabel : "No signal loaded — generate or load a signal to begin."
            font.family: "Stack Sans Headline"
            font.pixelSize: 12
            color: theme.secondaryText
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }

        FilterCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 140
            clip: true
            SignalPlot { anchors.fill: parent }
        }
    }

    FileDialog {
        id: wavDialog
        title: "Open WAV File"
        nameFilters: ["WAV files (*.wav)", "All files (*)"]
        onAccepted: simulation.loadWav(selectedFile.toString().replace("file://", ""))
    }
    FileDialog {
        id: csvDialog
        title: "Open CSV File"
        nameFilters: ["CSV files (*.csv *.txt)", "All files (*)"]
        onAccepted: simulation.loadCsv(selectedFile.toString().replace("file://", ""))
    }
}

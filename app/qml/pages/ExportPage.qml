import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

// ExportPage.qml — overflow-safe export UI
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
        spacing: 12

        Text {
            text: "Export Code"
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
            contentWidth: formatRow.implicitWidth
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentWidth > width

            Row {
                id: formatRow
                spacing: 8
                Repeater {
                    model: ["C", "C++ Header", "Python", "JSON"]
                    delegate: StyledButton {
                        required property int index
                        required property string modelData
                        text: modelData
                        primary: exportModel.format === index
                        implicitWidth: Math.max(72, Math.min(110, text.length * 9 + 24))
                        implicitHeight: 30
                        onClicked: {
                            exportModel.format = index
                            exportModel.generate(filterEngine)
                        }
                    }
                }
                Item { width: 8; height: 1 }
                StyledButton {
                    text: "Save As…"
                    primary: false
                    implicitWidth: 88
                    enabled: exportModel.code.length > 0
                    onClicked: saveDialog.open()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: filterEngine.filterResponseName() + " " + filterEngine.filterTypeName()
                  + "  ·  Order " + filterEngine.order
                  + "  ·  Fc " + filterEngine.cutoffFreq + " Hz"
                  + "  ·  Fs " + filterEngine.sampleRate + " Hz"
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
            CodeViewer {
                anchors.fill: parent
                code: exportModel.code
            }
        }
    }

    FileDialog {
        id: saveDialog
        title: "Save Code As"
        fileMode: FileDialog.SaveFile
        nameFilters: {
            const ext = [
                "C files (*.c)",
                "C++ headers (*.h)",
                "Python files (*.py)",
                "JSON files (*.json)"
            ]
            return [ext[exportModel.format], "All files (*)"]
        }
        onAccepted: exportModel.saveToFile(selectedFile.toString().replace("file://", ""))
    }

    Component.onCompleted: exportModel.generate(filterEngine)
}

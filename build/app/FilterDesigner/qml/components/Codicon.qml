import QtQuick

// Codicon.qml — Microsoft Codicons (VS Code icon font, CC-BY 4.0)
Text {
    id: root
    property string icon: "tools"
    property int iconSize: 16
    property color iconColor: theme.secondaryText

    font.family: "codicon"
    font.pixelSize: iconSize
    color: iconColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: root.glyph(icon)
    renderType: Text.QtRendering

    function glyph(name) {
        const map = {
            "tools":            "\uEB6D",
            "graph":            "\uEB03",
            "play":             "\uEB2C",
            "export":           "\uEBAC",
            "settings-gear":    "\uEB51",
            "book":             "\uEAA4",
            "info":             "\uEA74",
            "question":         "\uEB32",
            "lightbulb":        "\uEA61",
            "arrow-right":      "\uEA9C",
            "chevron-right":    "\uEAB6",
            "filter":           "\uEAF1",
            "beaker":           "\uEA79",
            "desktop-download": "\uEA78",
            "edit":             "\uEA73",
            "home":             "\uEB06",
            "library":          "\uEB9C",
            "notebook":         "\uEBAF",
            "pulse":            "\uEB31",
            "compass":          "\uEBD5",
            "symbol-misc":      "\uEB63",
            "dashboard":        "\uEACD",
            "preview":          "\uEB2F",
            "debug-start":      "\uEAD3",
            "link-external":    "\uEB14"
        }
        return map[name] || map["question"]
    }
}

pragma Singleton
import QtQuick

// Theme.qml — design tokens (colors come from C++ ThemeManager as `theme`)
QtObject {
    readonly property int fontSizeXS:  11
    readonly property int fontSizeS:   13
    readonly property int fontSizeM:   15
    readonly property int fontSizeL:   17
    readonly property int fontSizeXL:  20
    readonly property int fontSizeXXL: 28

    // Bundled Inter (OFL) — see fonts/NOTICE
    readonly property string fontFamily: "Inter"
    readonly property string iconFontFamily: "codicon"

    readonly property int spaceXS:  4
    readonly property int spaceS:   8
    readonly property int spaceM:  16
    readonly property int spaceL:  24
    readonly property int spaceXL: 40

    readonly property int radiusS:  8
    readonly property int radiusM: 12
    readonly property int radiusL: 16

    readonly property int animFast:   150
    readonly property int animNormal: 250
    readonly property int animSlow:   400

    readonly property int sidebarWidth: 200
    readonly property int activityBarWidth: 48

    readonly property string plotPhase:      "#FF9F0A"
    readonly property string plotGroupDelay: "#30D158"
    readonly property string plotImpulse:    "#BF5AF2"
    readonly property string plotStep:       "#FF375F"
}

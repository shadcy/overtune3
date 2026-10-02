import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import "components"

// InstallerApp.qml — Dedicated, standalone Overtune 3 Setup Wizard
InstallerUpdaterWindow {
    id: installerAppWindow
    isStandalone: true
    activeTab: 1
    visible: true

    Component.onCompleted: {
        openWindow(1)
    }

    onClosing: function(close) {
        Qt.quit()
    }
}

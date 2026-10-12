import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

QtObject {
    id: root

    property var appWindow: AppWindow {}

    property var splashWindow: SplashWindow {
        visible: true
        onTimeout: root.appWindow.visible = true
    }
}


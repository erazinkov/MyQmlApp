import QtQuick

import QtQuick.Controls
import QtQuick.Layouts


Window {
    id: root
    width: Screen.desktopAvailableWidth * 0.5
    height: Screen.desktopAvailableHeight * 0.5
    visible: true
    ColumnLayout {
        anchors.fill: parent
        StackLayout {
            id: navStackedLayout
            Layout.alignment: Qt.AlignCenter
            currentIndex: bar.currentIndex
            AppWindow {}
            Rectangle {
                id: splashImage0
                Layout.alignment: Qt.AlignCenter
                width: 50
                height: 50
                color: "green"
            }
            Rectangle {
                id: splashImage1
                Layout.alignment: Qt.AlignCenter
                width: 50
                height: 50
                color: "blue"
            }

        }
    TabBar {
        id: bar
        currentIndex: 1

        TabButton {
            text: qsTr("Home")
        }
        TabButton {
            text: qsTr("Home")
        }
        TabButton {
            text: qsTr("Discover")
        }
        onCurrentIndexChanged: {
            navStackedLayout.currentIndex = currentIndex;
            print("currentIndex changed to", currentIndex)
            // ...
        }
    }


    }


    // StackView {
    //     initialItem: SplashWindow
    // }

    // property var splashWindow: SplashWindow {
    //         visible: true
    //         onTimeout: root.window.visible = true
    //     }
}

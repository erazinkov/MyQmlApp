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


//    function exit() {
//        splashWindow.visible = false
//        splashWindow.timeout()
//    }

    //! [timer]
//    Timer {
//        interval: splashWindow.timeoutInterval; running: splashWindow.visible; repeat: false
//        onTriggered: splashWindow.exit()
//    }
    //! [timer]
}

//Item {
//    id: root

//    SplashWindow {}

////    Loader {
////        id: splashWindowLoader
////        asynchronous: false
////        anchors.fill: parent
////        source: "SplashWindow.qml"
//////        asynchronous: true
//////        visible: status == Loader.Ready
//////        onLoadingComplete: {
////////            splashWindowLoader.visible = false;
////////            appWindowLoader.visible = true;
//////        }
////    }

////    Rectangle {
////        width: 500
////        height: 500
//////        anchors.fill: parent
////        color: "green"
////    }

////    Loader {
////        id: appWindowLoader
////        asynchronous: true
////        anchors.fill: parent
////        source: "AppWindow.qml"
////        visible: false
////    }

//    // StackView {
//    //     initialItem: SplashWindow
//    // }

//    // property var splashWindow: SplashWindow {
//    //         visible: true
//    //         onTimeout: root.window.visible = true
//    //     }
//}

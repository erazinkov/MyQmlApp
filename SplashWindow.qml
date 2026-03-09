import QtQuick

Window {
    id: splash
    color: "transparent"
    title: "Splash Window"
    // modality: Qt.ApplicationModal
    // flags: Qt.SplashScreen
    property int timeoutInterval: 2000
    signal timeout

//! [splash-properties]
//! [screen-properties]
    // x: (Screen.width - splashImage.width) / 2
    // y: (Screen.height - splashImage.height) / 2
//! [screen-properties]
    width: splashImage.width
    height: splashImage.height

    // Image {
    //     id: splashImage
    //     source: Images.qtLogo
    //     TapHandler {
    //         onTapped: splash.exit()
    //     }
    // }
    Rectangle {
        id: splashImage
        width: 500
        height: 500
        color: "green"
    }

    function exit() {
        splash.visible = false
        splash.timeout()
    }

    //! [timer]
    Timer {
        interval: splash.timeoutInterval; running: splash.visible; repeat: false
        onTriggered: splash.exit()
    }
    //! [timer]
}

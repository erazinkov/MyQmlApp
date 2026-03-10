import QtQuick
import QtQuick.Controls

Window {
    id: splash
    color: "transparent"
    title: "Splash Window"
    modality: Qt.ApplicationModal
    flags: Qt.SplashScreen
    property int timeoutInterval: 1000
    signal timeout

    width: Screen.desktopAvailableWidth * 0.5
    height: Screen.desktopAvailableHeight * 0.5

    Label {
        id: splashText
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("SAI-GPS")
        font.pointSize: 100
        minimumPointSize: 10
        fontSizeMode: Text.Fit
        color: "white"
        background: Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.75
            radius: 5
        }
    }

    function exit() {
        splash.visible = false
        splash.timeout()
    }

    Timer {
        interval: splash.timeoutInterval; running: splash.visible; repeat: false
        onTriggered: splash.exit()
    }
}

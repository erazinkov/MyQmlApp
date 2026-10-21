import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string message: ""
    property int defaultTimeout: 5000
    property color backgroundColor: "black"
    property color textColor: "white"

    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    width: snackbarRowLayout.implicitWidth
    height: snackbarRowLayout.implicitHeight
    visible: snackbarRectangle.opacity > 0
    z: 100

    function show(msg, timeout) {
        root.message = msg
        snackbarRectangle.show(msg, timeout === undefined ? root.defaultTimeout : timeout)
    }

    function hide() {
        snackbarRectangle.hide()
    }

    Rectangle {
        id: snackbarRectangle
        anchors.fill: parent
        radius: 5
        color: root.backgroundColor
        opacity: 0

        Behavior on opacity { NumberAnimation { duration: 200 } }

        RowLayout {
            id: snackbarRowLayout
            anchors.fill: parent
            spacing: 5

            Text {
                id: snackbarText
                padding: 5
                color: root.textColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Button {
                flat: true
                icon.source: "qrc:/assets/icons/close.svg"
                icon.color: "white"
                icon.width: 24
                icon.height: 24
                display: AbstractButton.IconOnly
                implicitWidth: 32
                implicitHeight: 32
                padding: 0
                background: Item {}

                onClicked: root.hide()
            }

//            Button {
//                text: root.closeButtonText
//                flat: true
//                onClicked: root.hide()
//            }
        }

        Timer {
            id: snackbarTimer
            interval: root.defaultTimeout
            repeat: false
            onTriggered: root.hide()
        }

        function show(msg, timeout) {
            snackbarText.text = msg
            snackbarTimer.stop()
            opacity = 1
            if (timeout > 0) {
                snackbarTimer.interval = timeout
                snackbarTimer.start()
            }
        }

        function hide() {
            snackbarTimer.stop()
            opacity = 0
        }
    }
}

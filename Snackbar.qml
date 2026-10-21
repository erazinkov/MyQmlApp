import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string message: ""
    property int timeout: 5000
    property color backgroundColor: "black"
    property color textColor: "white"

    radius: 5
    color: root.backgroundColor
    width: snackbarRowLayout.implicitWidth
    height: snackbarRowLayout.implicitHeight
    opacity: 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    RowLayout {
        id: snackbarRowLayout
        anchors.fill: parent
        spacing: 5

        Text {
            text: root.message
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
            hoverEnabled: false
            background: Item {}
            onClicked: root.dismiss()
        }
    }

    Timer {
        id: timer
        interval: root.timeout
        onTriggered: root.dismiss()
    }

    function open() {
        opacity = 1
        if (root.timeout > 0) {
            timer.interval = root.timeout
            timer.start()
        }
    }

    // removes the bar synchronously from its parent, then destroys it
    function dismiss() {
        timer.stop()
        root.parent = null       // leaves Column immediately -> children.length drops
        root.destroy()           // deferred, but no one references it anymore
    }
}

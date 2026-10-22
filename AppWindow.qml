import QtQuick

import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import dbController

ApplicationWindow {
    id: window
    width: Screen.desktopAvailableWidth * 0.75
    height: Screen.desktopAvailableHeight * 0.75

    visible: false
    title: qsTr("SAI-GPS")


    header: ToolBar {
            ToolButton {
                Accessible.name: qsTr("Toggle navigation")
                icon.source: navigationDrawer.opened ? "qrc:/assets/icons/close.svg"
                                                     : "qrc:/assets/icons/side_navigation.svg"
                icon.width: 24
                icon.height: 24
                onClicked: {
                    if (navigationDrawer.opened) {
                        navigationDrawer.close();
                    } else {
                        navigationDrawer.open();
                    }
                }
            }
    }



    DatabaseController { id: databaseController}

    DensityPage {
        id: densityPage
    }
    MapPage {
        id: mapPage
    }

    Drawer {
        id: navigationDrawer
        y: header.height
        width: Math.min(window.width, window.height) / 3
        height: window.height - header.height

        ListView {
            id: listView
            focus: true
            currentIndex: 0
            anchors.fill: parent

            model: ListModel {
                ListElement { title: qsTr("Map"); source: "map" }
                ListElement { title: qsTr("Density"); source: "density" }
            }

            delegate: ItemDelegate {
                id: delegateItem
                width: ListView.view.width
                text: title
                highlighted: ListView.isCurrentItem

                required property int index
                required property var model
                required property string title
                required property string source

                onClicked: {
                    listView.currentIndex = index;

                    if (source === "map") {
                        stackView.pop();
                    }
                    if (source === "density") {
                        if (stackView.depth > 1) {
                            return;
                        }
                        stackView.push(densityPage);
                    }
                }
            }
            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mapPage
    }

    footer: Rectangle {
        implicitHeight: 32

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            spacing: 5

            Item { Layout.fillWidth: true }

            Label {
                id: clockLabel
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Timer {
            id: clockTimer
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
        }
    }



//    Component.onCompleted: {
//        dbController.operateConnectDb("Connection 0",
//                                      "QMYSQL",
//                                      "localhost",
//                                      "napdb",
//                                      "testuser",
//                                      "Dubna@1234",
//                                      "curr_meas");
//    }


    SnackbarManager {
        id: snackbarManager
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
    }

    Connections {
        target: databaseController
        function onConnectionStateChanged(result) {
            snackbarManager.show(`Database ${result ? "connected" : "disconnected"} successfully`)
        }
        function onErrorOccurred(errorText) {
            snackbarManager.show(errorText, 5000, "red")
        }
        function onInsertData(str) {
            snackbarManager.show(str, 3500)
        }
    }
}

import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: Screen.desktopAvailableWidth * 0.75
    height: Screen.desktopAvailableHeight * 0.75

    visible: false
    title: qsTr("SAI-GPS")

    header: ToolBar {
        RowLayout {
            spacing: 20
            anchors.fill: parent
            ToolButton {
                Accessible.name: qsTr("Toggle drawer")
                text: drawer.opened ? "\u{2715}" : "\u{2630}"
                onClicked:{
                        if (drawer.opened) {
                            drawer.close();
                        } else {
                            drawer.open();
                        }
                }
            }
        }
    }

    DensityPage {
        id: densityPage
    }
    MapPage {
        id: mapPage
    }

    Drawer {
        id: drawer
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
        implicitHeight: 28

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            Label {
                text: "..."
                elide: Label.ElideRight
                Layout.fillWidth: true
            }

            Label {
                id: clockLabel
                text: Qt.formatDateTime(new Date(), "hh:mm:ss")
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm:ss")
    }
}

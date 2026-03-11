import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: Screen.desktopAvailableWidth * 0.5
    height: Screen.desktopAvailableHeight * 0.5

    visible: true
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

    Drawer {
        id: drawer
        y: header.height
        width: Math.min(window.width, window.height) / 3 * 1
        height: window.height - header.height

        ListView {
            id: listView
            focus: true
            currentIndex: -1
            anchors.fill: parent

            model: ListModel {
                ListElement { title: qsTr("Map"); source: "MapPage.qml" }
                ListElement { title: qsTr("Density"); source: "DensityPage.qml" }
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
                    console.log(`${stackView.depth}`);
//                    if (stackView.depth > 1) {
//                        return;
//                    }
                    listView.currentIndex = index;
                    stackView.push(source);
                }
            }
            ScrollIndicator.vertical: ScrollIndicator { }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: {}


    }
}

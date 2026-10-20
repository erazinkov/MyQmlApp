import QtQuick 2.0
import QtQuick.Layouts 1.15
import QtLocation 5.15
import QtPositioning 5.15
import QtQuick.Controls 2.15

MapQuickItem {
    id: root

    property var map: null
    property PositionSource positionSource: null

    coordinate: positionSource ? positionSource.position.coordinate : QtPositioning.coordinate()
    anchorPoint.x: sourceItem.width / 2
    anchorPoint.y: sourceItem.height / 2


    sourceItem: Item {
        width: 20
        height: 20


        Item {
            anchors.fill: parent
            transform: Rotation {
                origin.x: width / 2
                origin.y: height / 2
                axis { x: 1; y: 0; z: 0 }
                angle: root.map ? root.map.tilt : 0
            }
            Rectangle {
                id: locationMarker
                anchors.fill: parent
                color: "red"
                border.color: "white"
                border.width: 1
                radius: 10
            }
            Rectangle {
                id: accuracyMarker
                visible: root.positionSource && root.positionSource.position.horizontalAccuracyValid
                anchors.centerIn: parent
                width: root.positionSource
                       ? Math.max(root.positionSource.position.horizontalAccuracy,
                                  root.positionSource.position.verticalAccuracy).toFixed(1)
                       : 0
                height: width
                color: Qt.rgba(255, 255, 255, 0.5)
                border.color: "white"
                border.width: 1
                radius: width / 2
                z: -1
            }
        }


        ColumnLayout{
            anchors.left: parent.right
            anchors.bottom: parent.top
            Label {
                padding: 5
                text: (root.positionSource && root.positionSource.position.speedValid)
                      ? root.positionSource.position.speed.toFixed(1)
                      : "..."
                color: "white"
                background: Rectangle {
                    color: "black"
                    radius: 5
                }
            }
//            Label {
//                padding: 5
//                text: (root.positionSource && root.positionSource.position.directionValid)
//                      ? root.positionSource.position.direction.toFixed(1)
//                      : "..."
//                color: "white"
//                background: Rectangle {
//                    color: "black"
//                    radius: 5
//                }
//            }
        }

    }
}

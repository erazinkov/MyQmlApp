import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import QtPositioning
import QtLocation

import dbController
import markerModel

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("SAI-GPS")

    function onSelectForTable(data) {
        markerModel.addData(data);
        console.log(`Data: ${data.length}`);

    }

    function onConnectDb(success, errorText) {
        console.log(`Database connected: ${success}, Error: ${errorText}`);
    }
    DatabaseController { id: dbController}

    MarkerModel { id: markerModel}

    Location {
        id: startLocation
//        coordinate: QtPositioning.coordinate(44.9778133, 42.012765)
        coordinate: QtPositioning.coordinate(56.76176699999999, 37.22133433333334)
    }

    PositionSource {
        id: positionSource
        name: "nmea"
        PluginParameter { name: "nmea.source"; value: "serial:/dev/ttyACM0" }
        PluginParameter { name: "nmea.baudrate"; value: 4800 }
        updateInterval: 1000 // Request updates every second
        active: true
        onPositionChanged: {
            if (startLocation.coordinate === QtPositioning.coordinate(0.0, 0.0)) {
                console.log("Initial");
                startLocation.coordinate = position.coordinate;
                console.log(startLocation.coordinate.longitude);
                console.log(startLocation.coordinate.latitude);
            }
        }
    }

    Plugin {
            id: mapPlugin
            name: "osm"
        }

    Map {
           id: map
           copyrightsVisible: false
           anchors.fill: parent
           plugin: mapPlugin
           center: QtPositioning.coordinate(56.76176699999999, 37.22133433333334)
           zoomLevel: (maximumZoomLevel - minimumZoomLevel) / 1.25

           function distance() {

               var point_topLeft = Qt.point(mi.x + mi.anchorPoint.x - r.width / 2, mi.y + mi.anchorPoint.y - r.height / 2);

               var point_topRight = Qt.point(mi.x + mi.anchorPoint.x + r.width / 2, mi.y + mi.anchorPoint.y + r.height / 2);
               var point_bottomRight = Qt.point(mi.x + mi.anchorPoint.x + r.width / 2, mi.y + mi.anchorPoint.y - r.height / 2);
               var point_bottomLeft = Qt.point(mi.x + mi.anchorPoint.x - r.width / 2, mi.y + mi.anchorPoint.y + r.height / 2);

               var coord_topLeft = map.toCoordinate(point_topLeft);
               var coord_topRight = map.toCoordinate(point_topRight);
               var coord_bottomRight = map.toCoordinate(point_bottomRight);
               var coord_bottomLeft = map.toCoordinate(point_bottomLeft);

               var point_center = Qt.point(mi.x + mi.anchorPoint.x, mi.y + mi.anchorPoint.y);

               if (coord_topLeft && coord_topRight) {
                   var distance = coord_topLeft.distanceTo(coord_topRight);
                   return distance;
               }
               return -1;
           }

           MapItemView {
               model: markerModel
               delegate: MapQuickItem {
                   coordinate: model.coordinate
                   sourceItem: Rectangle {
                       width: 2
                       height: 2
                       color: "red"
                       radius: 1
                   }
                   anchorPoint.x: sourceItem.width / 2
                   anchorPoint.y: sourceItem.height / 2
              }
           }

           MapQuickItem {
                       id: mi
                       // Initial map coordinates for the center of the rectangle
                       coordinate: map.center
//                       anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                       anchorPoint.x: r.width / 2
                       anchorPoint.y: r.height / 2

                       // The actual QtQuick item to be displayed
                       sourceItem: Rectangle {
                           id: r
                           width: 150
                           height: width
                           color: Qt.rgba(255, 255, 255, 0.5)

                           GridLayout {
                               id: g
                               anchors.fill: parent
                               rows: 1
                               columns: 1
                               rowSpacing: 0
                               columnSpacing: 0
                               Repeater {
                                   model: g.rows * g.columns
                                   delegate: Rectangle {
                                       Layout.fillWidth: true
                                       Layout.fillHeight: true
                                       color: Qt.rgba(255, 255, 255, 0.0)
                                       border.color: "black"
                                       border.width: 1
//                                       // Optional: Display the item number
//                                       Text {
//                                           text: index + 1
//                                           anchors.centerIn: parent
//                                       }
                                   }
                               }
                           }

                           ColumnLayout{
                               anchors.left: parent.right
                               anchors.top: parent.top
                               RowLayout{
                               Button {
                                   id: plusButton
                                   text: "+"
                                   onClicked: {
                                        g.rows = g.rows + 1;
                                        g.columns = g.rows;
                                   }
                               }
                               Button {
                                   id: minusButton
                                   text: "-"
                                   onClicked: {
                                       if (g.rows > 1) {
                                           g.rows = g.rows - 1;
                                           g.columns = g.rows;
                                       }
                                   }
                               }
                               }
                               RowLayout{
                               Label {
                                   padding: 5
                                   text: `${g.rows}x${g.columns}`
                                   color: "white"
                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }
                               }
                               Label {
                                   padding: 5
                                   text: map.distance().toFixed(0)
                                   color: "white"
                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }
                               }
                               Label {
                                   padding: 5
                                   text: (map.distance() / g.rows).toFixed(0)
                                   color: "white"
                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }
                               }
                               }
                           }
                           // MouseArea for handling drag events

                           MouseArea {
                               id: mouseArea
                               anchors.fill: parent
                               drag.target: parent
                               onPositionChanged: {
                                    var point = Qt.point(mi.x + mi.anchorPoint.x, mi.y + mi.anchorPoint.y);
                                    mi.coordinate = map.toCoordinate(point);
                               }
                           }
                           Rectangle {
                               width: 15
                               height: 15
                               radius: width / 2
                               color: "white"
                               border.color: "black"
                               border.width: 1
                               anchors.left: parent.right
                               anchors.bottom: parent.bottom
                               MouseArea {
                                   id: mouseAreaResize
                                   anchors.fill: parent
                                   cursorShape: Qt.SizeFDiagCursor // Resizing cursor
                                   onPressedChanged: {
                                       dragHandler.enabled = !pressed;
                                   }
                                   onPositionChanged: {
                                       if (pressed) {
                                           // Adjust parent width/height based on mouse movement
                                           var s = Math.max(mouseAreaResize.mouseX - width / 2, mouseAreaResize.mouseY - height / 2)
                                           r.width += s;
                                       }
                                   }
                               }
                           }

                       }
                   }

//           MapQuickItem {
//                       id: userMarker
//                       coordinate: positionSource.position.coordinate

//                       // Customize marker visual (e.g., a simple red dot)
//                       sourceItem: Rectangle {
//                           width: 20
//                           height: 20
//                           color: "red"
//                           border.color: "white"
//                           border.width: 2
//                           radius: 10
//                       }
//                       anchorPoint.x: sourceItem.width / 2
//                       anchorPoint.y: sourceItem.height / 2
//                   }


//           PinchHandler {
//               id: pinch
//               target: null
//               onActiveChanged: if (active) {
//                   map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
//               }
//               onScaleChanged: (delta) => {
//                   map.zoomLevel += Math.log2(delta)
//                   map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
//               }
//               onRotationChanged: (delta) => {
//                   map.bearing -= delta
//                   map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
//               }
//               grabPermissions: PointerHandler.TakeOverForbidden
//           }
           WheelHandler {
               id: wheel
               // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
               // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
               // and we don't yet distinguish mice and trackpads on Wayland either
               acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                                ? PointerDevice.Mouse | PointerDevice.TouchPad
                                : PointerDevice.Mouse
               rotationScale: 1/120
               property: "zoomLevel"
//               onActiveChanged: {
//                   var point = Qt.point(mi.x + mi.anchorPoint.x, mi.y + mi.anchorPoint.y);
//                   mi.coordinate = map.toCoordinate(point);
//               }
           }



           DragHandler {
               id: dragHandler
               target: null
               onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y);
           }
//           Shortcut {
//               enabled: map.zoomLevel < map.maximumZoomLevel
//               sequence: StandardKey.ZoomIn
//               onActivated: map.zoomLevel = Math.round(map.zoomLevel + 1)
//           }
//           Shortcut {
//               enabled: map.zoomLevel > map.minimumZoomLevel
//               sequence: StandardKey.ZoomOut
//               onActivated: map.zoomLevel = Math.round(map.zoomLevel - 1)
//           }

           // Initial bearing (0 = North up)
           bearing: 0
           Behavior on bearing {
            enabled: true
               RotationAnimation {
                   direction: RotationAnimation.Shortest
                   duration: 300
                   easing.type: Easing.Linear
               }
           }
           // Add button to rotate
           GridLayout {
               columns: 5
               rows: 1
               anchors.bottom: parent.bottom
               anchors.horizontalCenter: parent.horizontalCenter

               Button {
                   text: "-5°"
                   onClicked: map.bearing = (map.bearing - 5) % 360
               }
               Button {
                   text: "-1°"
                   onClicked: map.bearing = (map.bearing - 1) % 360
               }
               Button {
                   text: "0°"
                   onClicked: map.bearing = 0
               }
               Button {
                   text: "+1°"
                   onClicked: map.bearing = (map.bearing + 1) % 360
               }
               Button {
                   text: "+5°"
                   onClicked: map.bearing = (map.bearing + 5) % 360
               }
               Button {
                   text: "DB"
                   onClicked: {
                       dbController.operateSelectForTable("", {});
                   }
               }
           }
       }
       Component.onCompleted: {
           dbController.operateConnectDb("Connection 0",
                                         "QMYSQL",
                                         "localhost",
                                         "napdb",
                                         "testuser",
                                         "Dubna@123",
                                         "curr_meas");

           dbController.connectDb.connect(onConnectDb);
           dbController.selectForTable.connect(onSelectForTable);
       }
}

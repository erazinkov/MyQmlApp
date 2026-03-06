import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import QtPositioning
import QtLocation

import dbController
import markerModel
import processing

Window {
    width: Screen.desktopAvailableWidth * 0.5
    height: Screen.desktopAvailableHeight * 0.5

    visible: true
    title: qsTr("SAI-GPS")

    function onProcessingFinished(index, result) {
        var b = toolGridLayout.children[index]?.children[0];
        if (b) {
            b.text = result;
        }
    }

    function onSelectForTable(data) {
        markerModel.addData(data);
        processing.addData(data);
    }

    function onDelete() {
        markerModel.deleteData();
    }

    function onConnectDb(success, errorText) {
        console.log(`Database connected: ${success}, Error: ${errorText}`);
    }
    DatabaseController { id: dbController}

    MarkerModel { id: markerModel}

    Processing { id: processing}

    Location {
        id: startLocation
        coordinate: QtPositioning.coordinate(0.0, 0.0)
    }

    Location {
        id: miLocation
        coordinate: QtPositioning.coordinate(0.0, 0.0)
    }


    MouseArea {
        id: mouseAreaWindow
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        onPositionChanged: (mouse) => {
//            var c = map.toCoordinate(Qt.point(mouseAreaWindow.mouseX, mouseAreaWindow.mouseY));
//            console.log(`${c.latitude} ${c.longitude}`);
//            var c = map.toCoordinate(Qt.point(mouseAreaWindow.mouseX, mouseAreaWindow.mouseY));
//            console.log(`${Qt.point(mouse.x, mouse.y)}`);
        }
        onClicked: {
            menu.popup(parent, mouseAreaWindow.mouseX, mouseAreaWindow.mouseY)
        }
    }

    Menu {
        id: menu
        MenuItem {
            text: qsTr("Add markers")
            onTriggered: dbController.operateSelectForTable("", {})
        }
        MenuItem {
            text: qsTr("Delete markers")
            onTriggered: onDelete()

        }
        MenuItem {
            text: qsTr("Process")
            onTriggered: {
                var polygonsList = [];
                var point_topLeft = Qt.point(mi.x, mi.y);
                var point_bottomRight = Qt.point(mi.x + r.width, mi.y + r.height);
                var hor = (point_bottomRight.x - point_topLeft.x) / toolGridLayout.columns;
                var ver = (point_bottomRight.y - point_topLeft.y) / toolGridLayout.rows;
                for (var row = 0; row < toolGridLayout.rows; ++row) {
                    for (var column = 0; column < toolGridLayout.columns; ++column) {
                    polygonsList.push([
                                          map.toCoordinate(Qt.point(point_topLeft.x + column * hor, point_topLeft.y + row * ver)),
                                          map.toCoordinate(Qt.point(point_topLeft.x + (column + 1) * hor, point_topLeft.y + row * ver)),
                                          map.toCoordinate(Qt.point(point_topLeft.x + (column + 1) * hor, point_topLeft.y + (row + 1) * ver)),
                                          map.toCoordinate(Qt.point(point_topLeft.x + column * hor, point_topLeft.y + (row + 1) * ver)),
                                          map.toCoordinate(Qt.point(point_topLeft.x + column * hor, point_topLeft.y + row * ver)),
                                      ]
                                 );
                    }
                }
                processing.processDataTest1(polygonsList);
            }
        }
        MenuSeparator {}

        Menu {
            title: qsTr("Location")
            MenuItem {
                text: qsTr("Dubna")
                onTriggered: {
                    map.center = QtPositioning.coordinate(56.76176699999999, 37.22133433333334);
                }
            }
            MenuItem {
                text: qsTr("Stavropol_0")
                onTriggered: {
                    map.center = QtPositioning.coordinate(44.9778133, 42.012765);
                }
            }
            MenuItem {
                text: qsTr("Stavropol_1")
                onTriggered: {
                    map.center = QtPositioning.coordinate(45.37975713745419, 42.4504277671827);
                }
            }
        }

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
                startLocation.coordinate = position.coordinate;
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
           center: startLocation.coordinate
           zoomLevel: (maximumZoomLevel - minimumZoomLevel) / 1.25

           function distance() {
               var point_topLeft = Qt.point(mi.x, mi.y);
               var point_bottomRight = Qt.point(mi.x + r.width, mi.y + r.height);
               var coord_topLeft = map.toCoordinate(point_topLeft);
               var coord_bottomRight = map.toCoordinate(point_bottomRight);
               if (coord_topLeft && coord_bottomRight) {
                   var distance = coord_topLeft.distanceTo(coord_bottomRight) * Math.cos(Math.PI / 4.0);
                   return distance;
               }
               return -1;
           }

           MapItemView {
               model: markerModel
               delegate: MapQuickItem {
                   coordinate: model.coordinate
                   sourceItem: Rectangle {
                       width: 5
                       height: 5
                       color: "red"
                       radius: 2.5
                   }
                   anchorPoint.x: sourceItem.width / 2
                   anchorPoint.y: sourceItem.height / 2
              }
           }

           MapQuickItem {
                       id: mi
                       // Initial map coordinates for the center of the rectangle
                       coordinate: startLocation.coordinate
                       anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                       visible: miSwitch.checked
                       // The actual QtQuick item to be displayed
                       sourceItem: Rectangle {
                           id: r
                           width: 150
                           height: width
                           color: Qt.rgba(255, 255, 255, 0.5)
                           GridLayout {
                               id: toolGridLayout
                               anchors.fill: parent
                               rows: 1
                               columns: 1
                               rowSpacing: 0
                               columnSpacing: 0
                               Repeater {
                                   model: toolGridLayout.rows * toolGridLayout.columns
                                   delegate: Rectangle {
                                       Layout.fillWidth: true
                                       Layout.fillHeight: true
                                       color: Qt.rgba(255, 255, 255, 0.0)
                                       border.color: "black"
                                       border.width: 1
                                       property int index: model.index
                                       Label {
                                           anchors.centerIn: parent
                                           padding: 5
                                           text: ""
                                           color: "white"
                                           background: Rectangle {
                                               color: "black"
                                               radius: 5
                                               visible: parent.text.length
                                           }
                                       }
                                   }
                               }
                           }

                           ColumnLayout{
                               anchors.left: parent.right
                               anchors.top: parent.top
                               RowLayout{
                                   Button {
                                       id: plusButton
                                       implicitWidth: labelNumber.height
                                       implicitHeight: labelNumber.height
                                       text: "+"
                                       onClicked: {
                                            toolGridLayout.rows = toolGridLayout.rows + 1;
                                            toolGridLayout.columns = toolGridLayout.rows;
                                       }
                                   }
                                   Button {
                                       id: minusButton
                                       implicitWidth: labelNumber.height
                                       implicitHeight: labelNumber.height
                                       text: "-"
                                       onClicked: {
                                           if (toolGridLayout.rows > 1) {
                                               toolGridLayout.rows = toolGridLayout.rows - 1;
                                               toolGridLayout.columns = toolGridLayout.rows;
                                           }
                                       }
                                   }
                               }
                               RowLayout{
                               Label {
                                   id: labelNumber
                                   padding: 5
                                   text: `${toolGridLayout.rows}x${toolGridLayout.columns}`
                                   color: "white"
                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }
                               }
                               Label {
                                   padding: 5
                                   text: map.distance().toFixed(1)
                                   color: "white"
                                   background: Rectangle {
                                       color: "black"
                                       radius: 5
                                   }
                               }
                               Label {
                                   padding: 5
                                   text: (map.distance() / toolGridLayout.rows).toFixed(1)
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
                               drag.threshold: 0
                               onPositionChanged: (mouse) => {
                                   var xx = mi.x + r.x + r.width / 2;
                                   var yy = mi.y + r.y + r.height / 2;
                                   var newCoords = map.toCoordinate(Qt.point(xx, yy));
                                   mi.coordinate = newCoords;
                               }
                           }
                           Rectangle {
                               width: labelNumber.height * 0.5
                               height: width
                               radius: 2.5
                               color: "black"
                               anchors.left: parent.right
                               anchors.bottom: parent.bottom
                               MouseArea {
                                   id: mouseAreaResize
                                   anchors.fill: parent
                                   cursorShape: Qt.SizeFDiagCursor
                                   onPressedChanged: {
                                       dragHandler.enabled = !pressed;
                                   }
                                   onPositionChanged: {
                                       if (pressed) {
                                           var s = Math.max(mouseAreaResize.mouseX - width / 2, mouseAreaResize.mouseY - height / 2)
                                           r.width += s;
                                       }
                                   }
                               }
                           }

                       }
                   }


           MapQuickItem {
                       id: userMarker
                       coordinate: positionSource.position.coordinate

                       // Customize marker visual (e.g., a simple red dot)
                       sourceItem: Rectangle {
                           width: 10
                           height: 10
                           color: "red"
                           border.color: "white"
                           border.width: 1
                           radius: 5
                       }
                       anchorPoint.x: sourceItem.width / 2
                       anchorPoint.y: sourceItem.height / 2
                   }


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
               columns: 8
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
               Switch {
                   id: miSwitch
                    checked: false
                    onCheckedChanged: {
                        mi.coordinate = map.center;
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
           processing.finished.connect(onProcessingFinished);

//           markerModel.populateTest();
       }
}

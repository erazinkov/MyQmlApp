import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import QtPositioning
import QtLocation

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("SAI-GPS")

    Location {
        id: startLocation
        coordinate: QtPositioning.coordinate(0.0, 0.0)
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
//56.76189983333334
                startLocation.coordinate = position.coordinate;
                console.log(startLocation.coordinate.longitude);
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

//           MouseArea {
//                anchors.fill: parent
//                hoverEnabled: true
//                onPositionChanged: {
//                    var coordinate = map.toCoordinate(Qt.point(mouse.x, mouse.y));
////                    console.log(`x: ${mouse.x}, y: ${mouse.y}`);
//                    console.log(`Lat: ${coordinate.latitude.toFixed(4)}, Lon: ${coordinate.longitude.toFixed(4)}`);
//                }
//           }

           MapQuickItem {
                       id: mi1
                       // Initial map coordinates for the center of the rectangle
                       coordinate: startLocation.coordinate
//                       anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                       anchorPoint.x: r1.width / 2
                       anchorPoint.y: r1.height / 2

                       // The actual QtQuick item to be displayed
                       sourceItem: Rectangle {
                           id: r1
                           width: 350
                           height: 150
                           color: "green"
                           border.width: 2
                           opacity: 0.5
                           }
           }

           MapQuickItem {
                       id: mi
                       // Initial map coordinates for the center of the rectangle
                       coordinate: startLocation.coordinate
//                       anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
                       anchorPoint.x: r.width / 2
                       anchorPoint.y: r.height / 2

                       // The actual QtQuick item to be displayed
                       sourceItem: Rectangle {
                           id: r
                           width: 350
                           height: 150
                           color: "blue"
                           border.width: 2
                           opacity: 0.5

                           // MouseArea for handling drag events
                           MouseArea {
                               id: mouseArea
                               anchors.fill: parent
                               drag.target: parent
                               onPositionChanged: {
//                                   if (drag.active) {
                                       console.log(`${r.x} ${mouseArea.mouseX} ${mi.anchorPoint.x} ${mi.coordinate.longitude}`);
                                       var point = Qt.point(mi.x + mi.anchorPoint.x, mi.y + mi.anchorPoint.y);
//                                       console.log(`${map.toCoordinate(point).latitude} ${startLocation.coordinate.latitude}`);
                                       mi.coordinate = map.toCoordinate(point);
//                                       var point = Qt.point(mouse.x + draggableRectangleItem.anchorPoint.x, mouseArea.mouseY + draggableRectangleItem.anchorPoint.y);
//                                       draggableRectangleItem.coordinate = map.toCoordinate(point);
                                       // Convert local screen position of the mouse back to map coordinates
//                                       var coordinate = map.toCoordinate(Qt.point(mouseArea.mouseX + r.x + mi.anchorPoint.x,
//                                                                       mouseArea.mouseY + r.y + mi.anchorPoint.y));

//                                       mi.coordinate = coordinate;
//                                   }
                               }
                           }
//                           Rectangle {
//                               width: parent.width * 0.1
//                               height: parent.width * 0.1
//                               color: "red"
//                               anchors.right: parent.right
//                               anchors.bottom: parent.bottom
//                               MouseArea {
//                                   id: mouseAreaResize
//                                   anchors.fill: parent
//                                   cursorShape: Qt.SizeFDiagCursor // Resizing cursor
//                                   onPositionChanged: {
//                                       if (pressed) {

//                                           // Adjust parent width/height based on mouse movement
//                                           rect.width += mouseAreaResize.mouseX - width / 2;
//                                           rect.height += mouseAreaResize.mouseY - height / 2;
//                                       }
//                                   }
//                               }
//                           }

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
//           WheelHandler {
//               id: wheel
//               // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
//               // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
//               // and we don't yet distinguish mice and trackpads on Wayland either
//               acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
//                                ? PointerDevice.Mouse | PointerDevice.TouchPad
//                                : PointerDevice.Mouse
//               rotationScale: 1/120
//               property: "zoomLevel"
//           }
//           DragHandler {
//               id: drag
//               target: null
//               onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
//           }
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

//           // Initial bearing (0 = North up)
//           bearing: 0
//           Behavior on bearing {
//            enabled: true
//               RotationAnimation {
//                   direction: RotationAnimation.Shortest
//                   duration: 300
//                   easing.type: Easing.Linear
//               }
//           }
//           // Add button to rotate
//           GridLayout {
//               columns: 3
//               rows: 1
//               anchors.bottom: parent.bottom
//               anchors.horizontalCenter: parent.horizontalCenter

//               Button {
//                   text: "-5°"
//                   onClicked: map.bearing = (map.bearing - 5) % 360
//               }
//               Button {
//                   text: "0°"
//                   onClicked: map.bearing = 0
//               }
//               Button {
//                   text: "+5°"
//                   onClicked: map.bearing = (map.bearing + 5) % 360
//               }
//           }
       }
}

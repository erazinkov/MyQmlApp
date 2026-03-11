import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import QtPositioning
import QtLocation
import QtGraphs

import dbController
import pController
import markerModel


ApplicationWindow {
    id: window
    width: Screen.desktopAvailableWidth * 0.5
    height: Screen.desktopAvailableHeight * 0.5

    visible: true
    title: qsTr("SAI-GPS")




    Category3DAxis {
        id: rowAxis
        min: 0
        max: toolGridLayout.rows
    }
    Category3DAxis {
        id: columnAxis
        min: 0
        max: toolGridLayout.columns
    }
    Value3DAxis {
        id: valueAxis
        min: 0
        max: 100
    }



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

        Label {
            text: "TODO"
            anchors.centerIn: parent
        }
    }

    StackLayout {
        width: parent.width
        height: parent.height
        currentIndex: bar.currentIndex
        Item {
            id: mapTab
            width: parent.width
            height: parent.height
            function onProcessData(index, result, isProcess) {
                var a = toolGridLayout.children[index]?.children[0];
                var b = toolGridLayout.children[index]?.children[0]?.children[0]?.children[0];
                if (b) {
                    b.text = result;
                    if (!isProcess) {
                        var row    = Math.floor(index / toolGridLayout.rows)
                        var column = index % toolGridLayout.columns
                        console.log(`${row.toString()} ${column.toString()} ${result.toString()}`);
                        var max = valueAxis.max;
                        if (max < result) {
                            valueAxis.max = result;
                        }
                        dataModel.append({rowIdx: row.toString(), columnIdx: column.toString(), density: result.toString() });
                    }

                }
                if (a) {
                    a.currentIndex = isProcess ? 1 : 0;
                }
            }

            function onDelete() {
                markerModel.deleteData();
            }

            function onSelectForTable(data) {
                markerModel.addData(data);
                pController.operateAddData(data);
            }

            function f1() {}

            function onConnectDb(success, errorText) {
                console.log(`Database connected: ${success}, Error: ${errorText}`);
            }



            DatabaseController { id: dbController}

            ProcessingController { id: pController}

            MarkerModel { id: markerModel}

            Location {
                id: startLocation
                coordinate: QtPositioning.coordinate(0.0, 0.0)
            }

            ListModel {
                id: mapTypesModel
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
                    id: deleteMenuItem
                    text: qsTr("Delete markers")
                    onTriggered: mapTab.onDelete()

                }
                MenuItem {
                    text: qsTr("Process")
                    onTriggered: {
                        dataModel.clear();
                        rowAxis.max = toolGridLayout.rows - 1;
                        columnAxis.max = toolGridLayout.columns - 1;
                        var rowLabels = [];
                        for (var rowIdx = 0; rowIdx < toolGridLayout.rows; ++rowIdx) {
                            rowLabels.push(rowIdx.toString());
                        }
                        rowAxis.labels = rowLabels;

                        var columnLabels = [];
                        for (var columnIdx = 0; columnIdx < toolGridLayout.columns; ++columnIdx) {
                            columnLabels.push(columnIdx.toString());
                        }
                        columnAxis.labels = columnLabels;
                        valueAxis.max = 100;
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
                        pController.operateProcessData(polygonsList);
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

                MenuSeparator {}

                Menu {
                    id: mapTypeMenu
                    title: qsTr("Map type")
                    Repeater {
                        model: mapTypesModel
                        MenuItem {
                            text: mapTypeName
                            onTriggered: {
                                map.activeMapType = map.supportedMapTypes[index];
                            }

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
                                               StackLayout {
                                                   id: toolGridLayoutStackedLayout
                                                   anchors.fill: parent
                                                   currentIndex: 0
                                                   Rectangle {
                                                       Layout.alignment: Qt.AlignCenter
                                                       color: Qt.rgba(255, 255, 255, 0.0)
                                                       Label {
                                                           anchors.horizontalCenter: parent.horizontalCenter
                                                           anchors.verticalCenter: parent.verticalCenter
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
                                                   BusyIndicator {
                                                       Layout.alignment: Qt.AlignHCenter
                                                       running: true
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

                                   DragHandler {
                                       target: mi
                                       xAxis.minimum: r.border.width
                                       xAxis.maximum: window.width - r.width - r.border.width
                                       yAxis.minimum: r.border.width
                                       yAxis.maximum: window.height - r.height - r.border.width

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

                   bearing: 0 // north up
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
                   pController.processData.connect(onProcessData);

                   for (var i = 0; i < map.supportedMapTypes.length; ++i) {
                        mapTypesModel.append({ index: i, mapTypeName: map.supportedMapTypes[i].description });
                   }

                   //                 }
        //           processing.finished.connect(onProcessingFinished);

        //           markerModel.populateTest();
               }
        }

            Item {
                id: densityTab
                width: parent.width
                height: parent.height
                Bars3D {
                        width: parent.width
                        height: parent.height

                        columnAxis: columnAxis
                        rowAxis: rowAxis
                        valueAxis: valueAxis

                        barSpacing: Qt.size(0.0, 0.0)
                        barSpacingRelative: true
                        cameraZoomLevel: 95.0
                        theme: GraphsTheme {
                            colorScheme: GraphsTheme.ColorScheme.Light
                            labelBorderVisible: true
                            labelFont.pointSize: 35
                            labelBackgroundVisible: true
                            colorStyle: GraphsTheme.ColorStyle.RangeGradient
                            baseGradients: [customGradient]
                            Gradient {
                                id: customGradient
                                GradientStop { position: 0.0; color: "white" }
                                GradientStop { position: 0.2; color: "blue" }
                                GradientStop { position: 0.5; color: "green" }
                                GradientStop { position: 0.8; color: "yellow" }
                                GradientStop { position: 1.0; color: "red" }
                            }
                        }
                        cameraPreset: Graphs3D.CameraPreset.IsometricLeftHigh
                        Bar3DSeries {
                            itemLabelFormat: "@colLabel, @rowLabel: @valueLabel"
                            ItemModelBarDataProxy {
                                itemModel: dataModel
                                // Mapping model roles to bar series rows, columns, and values.
                                rowRole: "rowIdx"
                                columnRole: "columnIdx"
                                valueRole: "density"
                            }
                        }
                    }

                    ListModel {
                        id: dataModel
                        onDataChanged: {
                            console.log(data);
                        }
//                        ListElement{ rowIdx: 1; columnIdx: 1;     density: 4200; }
//                        ListElement{ rowIdx: "2022"; columnIdx: "Rauma";    density: "2100"; }
//                        ListElement{ rowIdx: "2022"; columnIdx: "Helsinki"; density: "7040"; }
//                        ListElement{ rowIdx: "2022"; columnIdx: "Tampere";  density: "4330"; }
//                        ListElement{ rowIdx: "2023"; columnIdx: "Oulu";     density: "3960"; }
//                        ListElement{ rowIdx: "2023"; columnIdx: "Rauma";    density: "1990"; }
//                        ListElement{ rowIdx: "2023"; columnIdx: "Helsinki"; density: "7230"; }
//                        ListElement{ rowIdx: "2023"; columnIdx: "Tampere";  density: "4650"; }
                    }
            }


        Item {
            id: activityTab
        }
    }

       footer: Item {
           width: parent.width
           height: bar.implicitHeight
           TabBar {
               id: bar
//               width: parent.width
               width: implicitWidth // Set the width to the sum of its buttons' implicit widths
               anchors.horizontalCenter: parent.horizontalCenter
               TabButton {
                   width: implicitWidth
                   text: qsTr("Map")
               }
               TabButton {
                   width: implicitWidth
                   text: qsTr("Density")
               }
           }
       }
}

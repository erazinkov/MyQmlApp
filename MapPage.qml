import QtQuick

import QtQuick.Controls

import QtPositioning
import QtLocation
import QtQuick.Layouts

import QtQuick.Shapes

import dbController
import markerModel

Page {
            id: page
            function onProcessData(index, result, isProcess, rows, columns) {
                var a = toolGridLayout.children[index]?.children[0];
                var b = toolGridLayout.children[index]?.children[0]?.children[0]?.children[0];
                if (b) {
                    b.text = result;
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
            property bool nearMeEnabled: false

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
                        pController.operateProcessData(polygonsList, toolGridLayout.rows, toolGridLayout.columns);
                    }
                }
                MenuSeparator {}

//                Menu {
//                    title: qsTr("Location")
//                    MenuItem {
//                        text: qsTr("Dubna")
//                        onTriggered: {
//                            map.center = QtPositioning.coordinate(56.76176699999999, 37.22133433333334);
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Stavropol_0")
//                        onTriggered: {
//                            map.center = QtPositioning.coordinate(44.9778133, 42.012765);
//                        }
//                    }
//                    MenuItem {
//                        text: qsTr("Stavropol_1")
//                        onTriggered: {
//                            map.center = QtPositioning.coordinate(45.37975713745419, 42.4504277671827);
//                        }
//                    }
//                }

            }
            PositionSource {
                id: positionSource
                name: "nmea"
                PluginParameter { name: "nmea.source"; value: "serial:/dev/ttyACM0" }
                PluginParameter { name: "nmea.baudrate"; value: 9600 }
                updateInterval: 1000 // Request updates every second
                active: true

                property var lastPositionCoordinate: null

                onPositionChanged: {
                    if (!positionSource.valid) {
                        return;
                    }
                    console.log(mapControls.nearMeChecked);
                    if (startLocation.coordinate === QtPositioning.coordinate(0.0, 0.0) || mapControls.nearMeChecked) {
                        startLocation.coordinate = Object.assign({}, position.coordinate);
                    }
//                    if (lastPosition && Math.abs(lastPosition.coordinate.latitude - position.coordinate.latitude)  < 1e-8 &&
//                        Math.abs(lastPosition.coordinate.longitude - position.coordinate.longitude) < 1e-8) {
                    if (lastPositionCoordinate) {
//                        console.log(lastPositionCoordinate.longitude, lastPositionCoordinate.latitude);
//                        console.log(position.coordinate.longitude, position.coordinate.latitude);
                    }
                    lastPositionCoordinate = { latitude:  position.coordinate.latitude, longitude:  position.coordinate.longitude};
//                    }
                }
            }

            MapView {
                id: mapView
                anchors.fill: parent
                map.copyrightsVisible: true
                map.plugin: Plugin {
                    name: "osm"
//                    PluginParameter {
//                        name: "osm.mapping.custom.host"
//                        value: "https://api.thunderforest.com/cycle/%z/%x/%y.png?apikey=e2d4258d86d743bc861d2a12cc3b67db"
//                    }
                }
                map.center: startLocation.coordinate
                map.zoomLevel: (maximumZoomLevel - minimumZoomLevel) / 1.25
            }
            CurrentLocationMarker {
                id: userMarker
                parent: mapView.map
                positionSource: positionSource
            }
            MapControls {
                id: mapControls
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5

                map: mapView.map

                onMapTypeClicked: {
                   dialog.open()
//                    if (mapTypeDrawer.opened) {
//                        mapTypeDrawer.close()
//                    } else {
//                        mapTypeDrawer.open()
//                    }
                }
                onMyLocationClicked: {
                    startLocation.coordinate = Object.assign({}, positionSource.position.coordinate)
                }
            }

/*
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








                   GridLayout {
                       columns: 1
                       rows: 1
                       anchors.bottom: parent.bottom
                       anchors.horizontalCenter: parent.horizontalCenter

                       Switch {
                           id: miSwitch
                            checked: false
                            onCheckedChanged: {
                                mi.coordinate = map.center;
                            }
                       }

                   }
                   Component.onCompleted: {
                           console.log("Supported map types:", supportedMapTypes.length)
//                           for (var i = 0; i < supportedMapTypes.length; i++) {
//                               console.log(i, supportedMapTypes[i].name, supportedMapTypes[i].type)
//                           }
                       }
                   activeMapType: {
                           if (supportedMapTypes.length > 0) {
                               return supportedMapTypes[supportedMapTypes.length - 1]
                           }
                           return undefined  // or leave it, will use default
                       }
                   Drawer {
                       id: mapTypeDrawer
                           edge: Qt.BottomEdge
//                           height: parent.height / 3
                           height: Math.min(parent.height, mapTypeFlow.childrenRect.height + 20)
                           width: parent.width


                           Flow {
                               id: mapTypeFlow
                               anchors.left: parent.left
                               anchors.right: parent.right
                               anchors.top: parent.top
                               anchors.margins: 10
                               spacing: 10

                               Repeater {
                                   model: mapTypesModel

                                   Button {
                                       text: mapTypeName
                                       padding: 10
                                       onClicked: {
                                           map.activeMapType = map.supportedMapTypes[index]
                                       }
                                   }
                               }
                             }

//                           ColumnLayout {
//                               anchors.fill: parent
//                               anchors.margins: 10
//                               Repeater {
//                                   model: mapTypesModel
//                                   Button {
//                                       text: mapTypeName
//                                       onClicked: {
//                                           map.activeMapType = map.supportedMapTypes[index];
//                                       }
//                                   }
//                                }
//                           }
                   }
               }
            */
               Component.onCompleted: {

                   console.log(Qt.resolvedUrl("qrc:/"))

//                   console.log("Resource exists:", Qt.resolvedUrl("qrc:/MyQmlApp/assets/icons/near_me.png"))

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
                   for (var i = 0; i < mapView.map.supportedMapTypes.length; ++i) {
                        mapTypesModel.append({ index: i, mapTypeName: mapView.map.supportedMapTypes[i].description });
                   }
               }

               Popup {
                   id: dialog
                   modal: true
                   focus: true
                   closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                   parent: parent.contentItem
                   anchors.centerIn: parent


                   ColumnLayout {
                       anchors.fill: parent
                       Repeater {
                           model: mapTypesModel
                           Button {
                               text: mapTypeName
                               onClicked: {
                                   mapView.map.activeMapType = mapView.map.supportedMapTypes[index]
                               }
                           }
                       }
                   }
               }
        }

//MapQuickItem {
//            id: mi
//            // Initial map coordinates for the center of the rectangle
//            coordinate: startLocation.coordinate
//            anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
//            visible: miSwitch.checked
////                               visible: true
//            // The actual QtQuick item to be displayed
//            sourceItem: Rectangle {
//                id: r
//                width: 150
//                height: width
//                color: Qt.rgba(255, 255, 255, 0.5)

//                GridLayout {
//                    id: toolGridLayout
//                    anchors.fill: parent
//                    rows: 1
//                    columns: 1
//                    rowSpacing: 0
//                    columnSpacing: 0
//                    Repeater {
//                        model: toolGridLayout.rows * toolGridLayout.columns
//                        delegate: Rectangle {
//                            Layout.fillWidth: true
//                            Layout.fillHeight: true
//                            color: Qt.rgba(255, 255, 255, 0.0)
//                            border.color: "black"
//                            border.width: 1
//                            property int index: model.index
//                            StackLayout {
//                                id: toolGridLayoutStackedLayout
//                                anchors.fill: parent
//                                currentIndex: 0
//                                Rectangle {
//                                    Layout.alignment: Qt.AlignCenter
//                                    color: Qt.rgba(255, 255, 255, 0.0)
//                                    Label {
//                                        anchors.horizontalCenter: parent.horizontalCenter
//                                        anchors.verticalCenter: parent.verticalCenter
//                                        padding: 5
//                                        text: ""
//                                        color: "white"
//                                        background: Rectangle {
//                                            color: "black"
//                                            radius: 5
//                                            visible: parent.text.length
//                                        }
//                                    }
//                                }
//                                BusyIndicator {
//                                    Layout.alignment: Qt.AlignHCenter
//                                    running: true
//                                }
//                            }

//                        }
//                    }
//                }

//                ColumnLayout{
//                    anchors.left: parent.right
//                    anchors.top: parent.top
//                    anchors.leftMargin: 5
//                    spacing: 5
//                    RowLayout{
//                        Button {
//                            id: plusButton
//                            implicitWidth: labelNumber.height
//                            implicitHeight: labelNumber.height
//                            text: "+"
//                            onClicked: {
//                                 toolGridLayout.rows = toolGridLayout.rows + 1;
//                                 toolGridLayout.columns = toolGridLayout.rows;
//                            }
//                        }
//                        Button {
//                            id: minusButton
//                            implicitWidth: labelNumber.height
//                            implicitHeight: labelNumber.height
//                            text: "-"
//                            onClicked: {
//                                if (toolGridLayout.rows > 1) {
//                                    toolGridLayout.rows = toolGridLayout.rows - 1;
//                                    toolGridLayout.columns = toolGridLayout.rows;
//                                }
//                            }
//                        }
//                    }

//                    RowLayout{
//                    Label {
//                        id: labelNumber
//                        padding: 5
//                        text: `${toolGridLayout.rows}x${toolGridLayout.columns}`
//                        color: "white"
//                        background: Rectangle {
//                            color: "black"
//                            radius: 5
//                        }
//                    }
//                    Label {
//                        padding: 5
//                        text: map.distance().toFixed(1)
//                        color: "white"
//                        background: Rectangle {
//                            color: "black"
//                            radius: 5
//                        }
//                    }
//                    Label {
//                        padding: 5
//                        text: (map.distance() / toolGridLayout.rows).toFixed(1)
//                        color: "white"
//                        background: Rectangle {
//                            color: "black"
//                            radius: 5
//                        }
//                    }
//                    }
//                }

//                DragHandler {
//                    target: mi
//                    xAxis.minimum: r.border.width
//                    xAxis.maximum: window.width - r.width - r.border.width
//                    yAxis.minimum: r.border.width
//                    yAxis.maximum: window.height - r.height - r.border.width

//                }
//                Rectangle {
//                    width: labelNumber.height * 0.5
//                    height: width
//                    radius: 2.5
//                    color: "black"
//                    anchors.left: parent.right
//                    anchors.bottom: parent.bottom
//                    anchors.leftMargin: 2.5
//                    MouseArea {
//                        id: mouseAreaResize
//                        anchors.fill: parent
//                        cursorShape: Qt.SizeFDiagCursor
//                        onPressedChanged: {
//                            dragHandler.enabled = !pressed;
//                        }
//                        onPositionChanged: {
//                            if (pressed) {
//                                var s = Math.max(mouseAreaResize.mouseX - width / 2, mouseAreaResize.mouseY - height / 2)
//                                r.width += s;
//                            }
//                        }
//                    }
//                }

//            }
//        }

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
                mapGridOverlay.setCellResult(index, result, isProcess)
            }

            function onDelete() {
                markerModel.deleteData();
            }

            function onSelectForTable(data) {
                markerModel.addData(data);
                pController.operateAddData(data);
            }

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

            ListModel { id: mapTypesModel }

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
                    onTriggered: mapGridOverlay.requestProcess()
                }
                MenuSeparator {}

                Menu {
                    title: qsTr("Location")
                    MenuItem {
                        text: qsTr("Dubna")
                        onTriggered: {
                            startLocation.coordinate = QtPositioning.coordinate(56.76176699999999, 37.22133433333334);
                        }
                    }
                    MenuItem {
                        text: qsTr("Stavropol_0")
                        onTriggered: {
                            startLocation.coordinate = QtPositioning.coordinate(44.9778133, 42.012765);
                        }
                    }
                    MenuItem {
                        text: qsTr("Stavropol_1")
                        onTriggered: {
                            startLocation.coordinate = QtPositioning.coordinate(45.37975713745419, 42.4504277671827);
                        }
                    }
                }

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
                        return
                    }
                    var p = position.coordinate
                    if (pathControls.updatePathChecked) {
                    var pts = pathMapPolyLine.path
                        pts.push(QtPositioning.coordinate(p.latitude, p.longitude))
                        pathMapPolyLine.path = pts
                    }

                    if (mapControls.nearMeChecked) {
                        mapView.map.center = p
                    }
                    if (startLocation.coordinate === QtPositioning.coordinate(0.0, 0.0) || mapControls.nearMeChecked) {
                        startLocation.coordinate = QtPositioning.coordinate(p.latitude, p.longitude)
                    }
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
            MapPolyline {
                id: pathMapPolyLine
                parent: mapView.map
                line.width: 3
                line.color: "green"
                path: []
            }

            CurrentLocationMarker {
                id: currentLocationMarker
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
                }
                onMyLocationClicked: {
                    startLocation.coordinate = Object.assign({}, positionSource.position.coordinate)
                }
            }
            PathControls {
                id: pathControls

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5

                onResetPathClicked: {
                    pathMapPolyLine.path = []
                }
            }



            MapItemView {
                model: markerModel
                parent: mapView.map
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
            MapGridOverlay {
                id: mapGridOverlay
                map: mapView.map
                mapView: mapView
                initialCoordinate: startLocation.coordinate
                gridSize: 150
                gridRows: 1
                gridColumns: 1
                parent: mapView.map
                overlayEnabled: mapGridOverlaySwitch.checked

                onCoordinateChanged: function(newCoordinate) {
                    console.log("Grid moved to:", coordinate.latitude,
                                        coordinate.longitude)
                }
                onProcessRequested: function(polygons, rows, columns) {
                    pController.operateProcessData(polygons, rows, columns)
                }
             }

             Switch {
                 id: mapGridOverlaySwitch
                 checked: false
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



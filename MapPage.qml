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
            property bool nearMeActive: false
            property bool initialPositionSourceHandled: true

            MarkerModel { id: markerModel}

            ListModel { id: mapTypesModel }
            ListModel {
                id: placesModel
                ListElement { placeId: "dubna";       title: qsTr("Dubna");       latitude: 56.761767; longitude: 37.221334 }
                ListElement { placeId: "stavropol_0"; title: qsTr("Stavropol 0"); latitude: 44.977813; longitude: 42.012765 }
                ListElement { placeId: "stavropol_1"; title: qsTr("Stavropol 1"); latitude: 45.379757; longitude: 42.450428 }
            }
            Location {
                id: startLocation
                coordinate: QtPositioning.coordinate(0.0, 0.0)
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
                    onTriggered: mapGridOverlay.requestProcess()
                }
            }
            PositionSource {
                id: positionSource
                name: "nmea"
                PluginParameter { name: "nmea.source"; value: "serial:/dev/ttyACM0" }
                PluginParameter { name: "nmea.baudrate"; value: 9600 }
                updateInterval: 1000 // Request updates every second
                active: true

                onPositionChanged: {
                    if (!positionSource.valid) {
                        return
                    }
                    var p = position.coordinate
                    if (!p.isValid) {
                        return
                    }

                    if (initialPositionSourceHandled) {
                        startLocation.coordinate = p
                        initialPositionSourceHandled = false
                    }

                    if (pathControls.updatePathChecked) {
                        var pts = pathMapPolyLine.path
                        var last = pts.length ? pts[pts.length - 1] : null
                        if (!last || last.distanceTo(p) > 1) {
                            pts.push(p)
                            pathMapPolyLine.path = pts
                        }
                    }

                    if (nearMeActive) {
                        mapView.map.center = p
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
                line.width: 5
                path: []
            }

            CurrentLocationMarker {
                id: currentLocationMarker
                map: mapView.map
                parent: mapView.map
                positionSource: positionSource
                z: 1
            }

            ColumnLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5
                spacing: 5

                Layout.alignment: Qt.AlignRight
                MapControls {
                    id: mapControls

                    map: mapView.map

                    onMapTypeClicked: {
                       dialogMapTypes.open()
                    }
                    onMyLocationClicked: {
                        var c = positionSource.position.coordinate
                        if (c.isValid) {
                            mapView.map.center = c
                            startLocation.coordinate = c
                        }
                    }
                    onPlacesClicked: {
                        var pt = placesButton.mapToItem(dialogPlaces.parent, 0, 0)
                        dialogPlaces.open()
                        // Place the menu so its right edge touches the button's left edge
                        dialogPlaces.x = pt.x - dialogPlaces.width
                        dialogPlaces.y = pt.y
//                        dialogPlaces.open()
                    }
                    onNearMeToggled: function(checked) {
                        nearMeActive = checked
                        if (checked) {
                            var c = positionSource.position.coordinate
                            if (c.isValid) {
                                mapView.map.center = c
                            }
                        } else {
                            mapView.map.center = startLocation.coordinate
                        }
                    }
                }
                PathControls {
                    id: pathControls
                    Layout.alignment: Qt.AlignRight
                    onResetPathClicked: {
                        pathMapPolyLine.path = []
                    }
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
                initialCoordinate: mapView.map.center
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
                     if (mapView.map.supportedMapTypes[i].description !== "Hiking map view") {
                         mapTypesModel.append({ index: i, mapTypeName: mapView.map.supportedMapTypes[i].description });
                     }
                 }
             }

             Popup {
                 id: dialogMapTypes
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
                             checkable: true
                             checked: mapView.map.activeMapType === mapView.map.supportedMapTypes[index]
                             onClicked: {
                                 mapView.map.activeMapType = mapView.map.supportedMapTypes[index]
                             }
                         }
                     }
                 }
             }

             Menu {
                 id: dialogPlaces
//                 modal: true
//                 closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                 Repeater {
                     model: placesModel
                     delegate: MenuItem {
                         required property string title
                         required property real   latitude
                         required property real   longitude
                         text: title
                         onTriggered: {
                             mapView.map.center = QtPositioning.coordinate(latitude, longitude)
                             dialogPlaces.close()
                         }
                     }
                 }
             }
        }



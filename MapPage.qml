import QtQuick

import QtQuick.Controls

import QtPositioning
import QtLocation
import QtQuick.Layouts

import QtQuick.Shapes

import markerModel

Page {
            id: page
            function onProcessData(index, result, isProcess, rows, columns) {
                mapGridOverlay.setCellResult(index, result, isProcess)
            }

            function onDelete() {
                markerModel.deleteData();
            }

            property bool nearMeActive: false
            property bool uploadDatabaseActive: false
            property bool initialPositionSourceHandled: true

            property int n: 0


//            Connections {
//                target: dbController
//                function onSelectForTable(data) {
//                    markerModel.addData(data);
//                    pController.operateAddData(data);
//                }

//                function onConnectDb(success, errorText) {
//                    console.log(`Database connected: ${success}, Error: ${errorText}`);
//                    databaseControls.connectDatabase = success
//                }

//                function onDisconnectDb() {
//                    databaseControls.connectDatabase = false
//                }
//            }

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
                    onTriggered: databaseController.operateSelectForTable("", {})
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

                    if (uploadDatabaseActive) {
                        var now = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
                        databaseController.operateInsertData(n, now, "test1", p.latitude, p.longitude, "GPS")
                        n++;
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
                opacity: 0.75
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
                       mapTypesDialog.open()
                    }
                    onMyLocationClicked: {
                        var c = positionSource.position.coordinate
                        if (c.isValid) {
                            mapView.map.center = c
                            startLocation.coordinate = c
                        }
                    }
                    onPlacesClicked: {
                        var pt = placesButton.mapToItem(placesDialog.parent, 0, 0)
                        placesDialog.open()
                        placesDialog.x = pt.x - placesDialog.width
                        placesDialog.y = pt.y
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
                DatabaseControls {
                    id: databaseControls
                    Layout.alignment: Qt.AlignRight

                    onUploadDatabaseToggled: function(checked) {
                        if (!checked) {
                            n = 0
                        }
                        uploadDatabaseActive = checked
                    }

                    onSettingsDatabaseClicked: {
                        databaseSettingsDialog.open()
                    }
                    onSearchDatabaseClicked: {
                        databaseController.operateSelectForTable("", {})
                    }
                    onConnectDatabaseClicked: {
                        databaseController.operateConnectDatabase(
                                    databaseSettingsDialog.current.connectionName,
                                    databaseSettingsDialog.current.driver,
                                    databaseSettingsDialog.current.hostName,
                                    databaseSettingsDialog.current.databaseName,
                                    databaseSettingsDialog.current.userName,
                                    databaseSettingsDialog.current.password)
                    }
                    onDisconnectDatabaseClicked: {
                        databaseController.operateDisconnectDatabase()
                    }
                    Connections {
                        target: databaseController
                        function onSelectForTable(data) {
                            markerModel.addData(data);
                            pController.operateAddData(data);
                        }

                        function onConnectionStateChanged(result) {
                            databaseControls.connectionState = result
                        }
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
//                initialCoordinate: QtPositioning.coordinate(56.761767, 37.221334)
                gridSize: 150
                gridRows: 1
                gridColumns: 1
                parent: mapView.map
                overlayEnabled: mapGridOverlaySwitch.checked
                z: 10000


//                onCoordinateChanged: function(newCoordinate) {
//                    console.log("Grid moved to:", coordinate.latitude,
//                                        coordinate.longitude)
//                }
                onProcessRequested: function(polygons, rows, columns) {
                    pController.operateProcessData(polygons, rows, columns)
                }
                Connections {
                    target: mapView.map
                    function onBearingChanged() {
                        mapGridOverlay.distance()
                    }
                }
             }

             Switch {
                 id: mapGridOverlaySwitch
                 checked: false
             }

             Component.onCompleted: {
//                 dbController.connectDb.connect(onConnectDb);
//                 dbController.selectForTable.connect(onSelectForTable);
                 pController.processData.connect(onProcessData);
                 for (var i = 0; i < mapView.map.supportedMapTypes.length; ++i) {
                     if (mapView.map.supportedMapTypes[i].description !== "Hiking map view") {
                         mapTypesModel.append({ index: i, mapTypeName: mapView.map.supportedMapTypes[i].description });
                     }
                 }
             }

             Popup {
                 id: mapTypesDialog
                 modal: true
                 focus: true
                 closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
//                 parent: parent.contentItem
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
                 id: placesDialog
                 Repeater {
                     model: placesModel
                     delegate: MenuItem {
                         required property string title
                         required property real   latitude
                         required property real   longitude
                         text: title
                         onTriggered: {
                             mapView.map.center = QtPositioning.coordinate(latitude, longitude)
                             placesDialog.close()
                         }
                     }
                 }
             }



             Dialog {
                 id: databaseSettingsDialog
                 title: "Database Settings"
                 modal: true
                 focus: true
                 anchors.centerIn: parent

                 property var defaults: ({
                    connectionName: "Connection 0",
                    driver:         "QMYSQL",
                    hostName:       "localhost",
                    databaseName:   "napdb",
                    userName:       "testuser",
                    password:       "Dubna@123"
                 })

                 property var current: ({})

                 function loadValues(values) {
                    current = Object.assign({}, defaults, values || {})
                    connectionNameTextField.text = current.connectionName
                    driverComboBox.currentIndex = Math.max(0, driverComboBox.model.indexOf(current.driver))
                    hostNameTextField.text   = current.hostName
                    databaseNameTextField.text = current.databaseName
                    userNameTextField.text   = current.userName
                    passwordTextField.text    = current.password
                 }

                 function saveValues() {
                    current = {
                        connectionName: connectionNameTextField.text,
                        driver:         driverComboBox.currentText,
                        hostName:       hostNameTextField.text,
                        databaseName:   databaseNameTextField.text,
                        userName:       userNameTextField.text,
                        password:       passwordTextField.text
                    }
                    return current
                 }

                 Component.onCompleted: loadValues(defaults)
                 onOpened: loadValues(current)

                 GridLayout {
                     columns: 2
                     anchors.fill: parent
                     rowSpacing: 5
                     columnSpacing: 5

                     Label { text: qsTr("Connection\'s name:") }
                     TextField { id: connectionNameTextField; Layout.fillWidth: true }

                     Label { text: qsTr("Driver:") }
                     ComboBox {
                         id: driverComboBox
                         Layout.fillWidth: true
                         model: ["QSQLITE", "QMYSQL", "QPSQL", "QODBC"]
                     }

                     Label { text: qsTr("Database Host:") }
                     TextField { id: hostNameTextField; Layout.fillWidth: true }

                     Label { text: qsTr("Database\'s name:") }
                     TextField { id: databaseNameTextField; Layout.fillWidth: true }

                     Label { text: qsTr("Database\'s user:") }
                     TextField { id: userNameTextField; Layout.fillWidth: true }

                     Label { text: qsTr("Password:") }
                     TextField { id: passwordTextField; Layout.fillWidth: true; echoMode: TextInput.Password }
                 }
                 footer: DialogButtonBox {
                     Button {
                        text: qsTr("Reset")
                        onClicked: {
                            databaseSettingsDialog.loadValues(databaseSettingsDialog.defaults)
                        }
                     }
                     Button {
                        text: qsTr("Cancel")
                        DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
                        onClicked: {
                            databaseSettingsDialog.close()
                        }
                     }
                     Button {
                        text: qsTr("Ok")
                        DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
                        onClicked: {
                            var s = databaseSettingsDialog.saveValues()
                            databaseSettingsDialog.accept()
                        }
                     }
                     Button {
                        text: qsTr("Test")
                        onClicked: {

                        }
                     }
                 }
             }


             //44.98123315320525 42.008523822560335
             //150.8
             //17
//             readonly property var    center_:   QtPositioning.coordinate(56.761767, 37.221334)
             readonly property var    center_:   QtPositioning.coordinate(44.98123315320525, 42.008523822560335)
             readonly property real   size_:     150.8
             readonly property real   bearing_:  17

             MapQuickItem {
                 id: densityMapQuickItem
                     parent: mapView.map
                     coordinate: center_
                     z: 10000
                     anchorPoint: Qt.point(densityImage.width / 2, densityImage.height / 2)

                     sourceItem: Image {
                         id: densityImage
                         source: "file:///home/egor/MyQmlApp/matrix_hist.png"
                         antialiasing: true
                         mipmap: true
                         width: 100
                         height: 100
                         opacity: 0.8
                         transform: [
                             Rotation {
                                origin.x: densityImage.width / 2
                                origin.y: densityImage.height / 2
                                axis { x: 0; y: 0; z: 1 }
                                angle: bearing_ - mapView.map.bearing
                             },
                             Rotation {
                                origin.x: densityImage.width / 2
                                origin.y: densityImage.height / 2
                                axis { x: 1; y: 0; z: 0 }
                                angle: mapView.map.tilt
                             }
                         ]
                     }
                     function updateSize() {
                         if (!mapView.map.mapReady) {
                             return
                         }
                         var lat = center_.latitude
                         var mpp = 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, mapView.map.zoomLevel)
                         var sidePx = size_ / mpp
                         densityImage.width  = sidePx
                         densityImage.height = sidePx
                     }

                     Connections {
                         target: mapView.map
                         function onMapReadyChanged()   { densityMapQuickItem.updateSize() }
                         function onZoomLevelChanged()  { densityMapQuickItem.updateSize() }
                         function onTiltChanged() { densityMapQuickItem.updateSize() }
                         function onCenterChanged()     { densityMapQuickItem.updateSize() }
                     }

                     Component.onCompleted: {
                         updateSize()
//                         Qt.callLater(function() { bearing_ = 45 })
                     }

                 }


//             MapQuickItem {
//                 id: densityMapQuickItem
//                     // Known geographic anchor center
//                     parent: mapView.map
//                     coordinate: center_

//                     // Match the center point of your item to the coordinate
//                     anchorPoint: Qt.point(densityRectangle.width / 2, densityRectangle.height / 2)

//                     sourceItem: Rectangle {
//                         id: densityRectangle
//                         width: 100  // Dimensions in screen pixels
//                         height: 100
//                         color: "blue"
//                         border.color: "white"
//                         border.width: 1

//                         // Rotate the screen item around its exact center
//                         transform: Rotation {
//                             origin.x: densityRectangle.width / 2
//                             origin.y: densityRectangle.height / 2
//                             angle: bearing_
//                         }
//                     }
//                     function updateSize() {
//                         if (!mapView.map.mapReady) {
//                             return
//                         }
//                         var lat = center_.latitude
//                         var mpp = 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, mapView.map.zoomLevel)
//                         var sidePx = size_ / mpp
//                         densityRectangle.width  = sidePx
//                         densityRectangle.height = sidePx
//                     }

//                     Connections {
//                         target: mapView.map
//                         function onMapReadyChanged()   { densityMapQuickItem.updateSize() }
//                         function onZoomLevelChanged()  { densityMapQuickItem.updateSize() }
////                         function onCenterChanged()     { densityMapQuickItem.updateSize() }
//                     }

//                     Component.onCompleted: {
//                         updateSize()
////                         Qt.callLater(function() { bearing_ = 45 })
//                     }

//                 }

//             MapQuickItem {
//                     id: densityMapQuickItem
//                     parent: mapView.map
//                     coordinate: center_
////                     anchorPoint.x: densityMapQuickItem.sourceItem ? densityMapQuickItem.sourceItem.width  / 2 : 0
////                     anchorPoint.y: densityMapQuickItem.sourceItem ? densityMapQuickItem.sourceItem.height / 2 : 0

//                     sourceItem: Item {
//                         id: densityItem
//                         width: 10
//                         height: 10
////                         anchors.centerIn: parent
//                         rotation: bearing_          // rotates around Item.Center by default
//                         transformOrigin: Item.Center

//                         Rectangle {
//                             anchors.fill: parent
//                             color: "blue"
//                             border.color: "black"
//                             border.width: 1
//                         }
//                     }

//                     function updateSize() {
//                         if (!mapView.map.mapReady) {
//                             return
//                         }
//                         var lat = center_.latitude
//                         var mpp = 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, mapView.map.zoomLevel)
//                         var sidePx = size_ / mpp
//                         console.log("sidePx", sidePx)
//                         densityItem.width  = sidePx
//                         densityItem.height = sidePx
//                         densityMapQuickItem.anchorPoint.x = densityItem ? densityItem.width  / 2 : 0
//                         densityMapQuickItem.anchorPoint.y = densityItem ? densityItem.height  / 2 : 0

//                     }

//                     Connections {
//                         target: mapView.map
//                         function onMapReadyChanged()   { densityMapQuickItem.updateSize() }
//                         function onZoomLevelChanged()  { densityMapQuickItem.updateSize() }
////                         function onCenterChanged()     { densityMapQuickItem.updateSize() }
//                     }

//                     Component.onCompleted: {
//                         updateSize()
//                         // Rotate 45° after everything is laid out
//                         Qt.callLater(function() { bearing_ = 45 })
//                     }
//                 }
//             MapQuickItem {
//                 id: topLeftMarker
//                 parent: mapView.map
//                 coordinate: center
//                 sourceItem: Item {
//                     id: topLeftItem
//                     anchors.centerIn: parent
//                     width: 0
//                     height: 0
//                     Rectangle {
//                         anchors.centerIn: parent
//                         anchors.fill: parent
//                         color: "red"
//                         border.color: "white"
//                         border.width: 1
//                     }
//                 }
//                 Connections {
//                     target: mapView.map
//                     function onMapReadyChanged() {
//                         if (mapView.map.mapReady) {
//                             topLeftMarker.zoomLevel = mapView.map.zoomLevel
//                             var tL = mapView.map.fromCoordinate(topLeft, false);
//                             var bR = mapView.map.fromCoordinate(bottomRight, false);
//                             console.log("width", bR.x - tL.x);
//                             console.log("height", bR.y - tL.y);
//                             console.log(topLeft.distanceTo(bottomRight) * Math.cos(Math.PI / 4.0))
//                             topLeftItem.width = (bR.x - tL.x);
//                             topLeftItem.height = (bR.y - tL.y);
//                             topLeftItem.rotation = bearing;
//                         }
//                     }

//                 }
//             }



//             MapQuickItem {
//                 id: bottomRightMarker
//                 parent: mapView.map
//                 coordinate: bottomRight
//                 sourceItem: Item {
//                     id: bottomRightItem
//                     width: 20
//                     height: 20
//                     Rectangle {
//                         anchors.centerIn: parent
//                         anchors.fill: parent
//                         color: "red"
//                         border.color: "white"
//                         border.width: 1
//                         radius: 10
//                     }

//                 }

//             }
        }



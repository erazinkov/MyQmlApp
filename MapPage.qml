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
            width: parent.width
            height: parent.height
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
                PluginParameter { name: "nmea.baudrate"; value: 9600 }
                updateInterval: 1000 // Request updates every second
                active: true

                property var lastPositionCoordinate: null

                onPositionChanged: {
                    if (!positionSource.valid) {
                        return;
                    }
                    if (startLocation.coordinate === QtPositioning.coordinate(0.0, 0.0) || nearMeButton.checked) {
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

            Plugin {
                    id: mapPlugin
                    name: "osm"
//                    PluginParameter {
//                        name: "osm.mapping.custom.host"
//                        value: "https://api.thunderforest.com/cycle/%z/%x/%y.png?apikey=e2d4258d86d743bc861d2a12cc3b67db"
//                    }
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
//                               visible: true
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
                                       anchors.leftMargin: 5
                                       spacing: 5
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
                                       anchors.leftMargin: 2.5
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
                               sourceItem: Rectangle {
                                   width: 20
                                   height: 20
                                   color: "red"
                                   border.color: "white"
                                   border.width: 1
                                   radius: 10
                                   ColumnLayout{
                                       anchors.left: parent.right
                                       anchors.bottom: parent.top
                                   Label {
                                       padding: 5
                                       text: positionSource.position.speedValid ? positionSource.position.speed.toFixed(1) : "..."
                                       color: "white"
                                       background: Rectangle {
                                           color: "black"
                                           radius: 5
                                       }
                                   }
//                                   Label {
//                                       padding: 5
//                                       text: positionSource.position.directionValid ? positionSource.position.direction.toFixed(1) : "..."
//                                       color: "white"
//                                       background: Rectangle {
//                                           color: "black"
//                                           radius: 5
//                                       }
//                                   }
                                   }
                                   Rectangle {
                                       id: accuracyMarker
                                       visible: positionSource.position.horizontalAccuracyValid
                                       anchors.centerIn: parent
                                       width: Math.max(positionSource.position.horizontalAccuracy, positionSource.position.verticalAccuracy).toFixed(1)
                                       height: width
                                       color: Qt.rgba(255, 255, 255, 0.5)
                                       border.color: "white"
                                       border.width: 1
                                       radius: width / 2
                                       z: -1
                                   }
                               }
                               anchorPoint.x: sourceItem.width / 2
                               anchorPoint.y: sourceItem.height / 2
                           }
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
                   bearing: 0 // north up
                   Behavior on bearing {
                    enabled: true
                       RotationAnimation {
                           direction: RotationAnimation.Shortest
                           duration: 300
                           easing.type: Easing.Linear
                       }
                   }

                   ColumnLayout {
                       anchors.right: parent.right
                       anchors.verticalCenter: parent.verticalCenter
                       anchors.rightMargin: 5
                       spacing: 5
                       Button {
                           id: mapTypeButton
                           Layout.alignment: Qt.AlignRight
                           icon.source: "qrc:/assets/icons/map.png"
                           icon.color: "black"
                           icon.width: 32
                           icon.height: 32
                           display: AbstractButton.IconOnly
                           implicitWidth: 32
                           implicitHeight: 32
                           padding: 0

                           onClicked:{
                                   if (mapTypeDrawer.opened) {
                                       mapTypeDrawer.close();
                                   } else {
                                       mapTypeDrawer.open();
                                   }
                           }
                       }
                       RowLayout {
                           Button {
                               id: rightRotationButton
                               icon.source: "qrc:/assets/icons/rotate_right.png"
                               icon.color: "black"
                               icon.width: 32
                               icon.height: 32
                               display: AbstractButton.IconOnly
                               implicitWidth: 32
                               implicitHeight: 32
                               padding: 0

                               autoRepeat: true
                               autoRepeatDelay: 500
                               autoRepeatInterval: 100

                               onClicked: map.bearing = (map.bearing + 1) % 360
                           }
                           Button {
                               id: leftRotationButton
                               icon.source: "qrc:/assets/icons/rotate_left.png"
                               icon.color: "black"
                               icon.width: 32
                               icon.height: 32
                               display: AbstractButton.IconOnly
                               implicitWidth: 32
                               implicitHeight: 32
                               padding: 0

                               autoRepeat: true
                               autoRepeatDelay: 500
                               autoRepeatInterval: 100

                               onClicked: map.bearing = (map.bearing - 1) % 360

                           }
                           Button {
                               id: northButton
                               implicitWidth: 32
                               implicitHeight: 32

                               contentItem: Image {
                                    source: "qrc:/assets/icons/north.png"
                                    sourceSize.width: 24
                                    sourceSize.height: 24
                                    fillMode: Image.PreserveAspectFit
                                    rotation: -map.bearing
                                    transformOrigin: Item.Center
                               }

                               onClicked: {
                                    map.bearing = 0
                               }
                           }
                       }
                       Button {
                           id: nearMeButton
                           Layout.alignment: Qt.AlignRight
                           checkable: true
                           checked: false
                           icon.source: checked ? "qrc:/assets/icons/near_me.png" : "qrc:/assets/icons/near_me_disabled.png"
                           icon.color: "black"
                           icon.width: 32
                           icon.height: 32
                           display: AbstractButton.IconOnly
                           implicitWidth: 32
                           implicitHeight: 32
                           padding: 0
                       }
                       Button {
                           id: myLocationButton
                           Layout.alignment: Qt.AlignRight
                           icon.source: "qrc:/assets/icons/my_location.png"
                           icon.color: "black"
                           icon.width: 32
                           icon.height: 32
                           display: AbstractButton.IconOnly
                           implicitWidth: 32
                           implicitHeight: 32
                           padding: 0

                           onClicked: {
                                startLocation.coordinate = Object.assign({}, positionSource.position.coordinate);
                           }
                       }
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
                       y: map.height / 2
                       width: Math.min(window.width, window.height) / 3
                       height: (window.height - map.height) / 2

                       ListView {
                           id: listView
                           focus: true
                           currentIndex: 0
                           anchors.fill: parent

                           model: ListModel {
                               ListElement { title: qsTr("Map"); source: "map" }
                               ListElement { title: qsTr("Density"); source: "density" }
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

//                               onClicked: {
//                                   listView.currentIndex = index;

//                                   if (source === "map") {
//                                       stackView.pop();
//                                   }
//                                   if (source === "density") {
//                                       if (stackView.depth > 1) {
//                                           return;
//                                       }
//                                       stackView.push(densityPage);
//                                   }
//                               }
                           }
                           ScrollIndicator.vertical: ScrollIndicator { }
                       }
                   }
               }
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
                   for (var i = 0; i < map.supportedMapTypes.length; ++i) {
                        mapTypesModel.append({ index: i, mapTypeName: map.supportedMapTypes[i].description });
                   }
               }
        }

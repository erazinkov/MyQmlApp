import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning

MapQuickItem {
    id: root

    property var map: null
    property var mapView: null
    property var initialCoordinate: null

    property real gridSize: 150

    property int gridRows: 1
    property int gridColumns: 1

    readonly property real diagonalDistance: distance()

    property bool overlayEnabled: true
    onOverlayEnabledChanged: {
        if (overlayEnabled) {
            recenter()
        }
    }

    signal processRequested(var polygonsList, int rows, int columns)

    anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
    visible: overlayEnabled

    coordinate: initialCoordinate !== null
               ? initialCoordinate
               : (map ? map.center : QtPositioning.coordinate(0, 0))




    function distance() {
        if (!map) return -1

        var point_topLeft     = Qt.point(root.x, root.y)
        var point_bottomRight = Qt.point(root.x + sourceItem.width,
                                         root.y + sourceItem.height)

        var coord_topLeft     = map.toCoordinate(point_topLeft)
        var coord_bottomRight = map.toCoordinate(point_bottomRight)



        if (coord_topLeft && coord_bottomRight) {
            var coord_center = QtPositioning.coordinate(
                        (coord_topLeft.latitude  + coord_bottomRight.latitude)  / 2,
                        (coord_topLeft.longitude + coord_bottomRight.longitude) / 2
                    )

//            console.log("topLeft", coord_topLeft.latitude, coord_topLeft.longitude)
//            console.log("bottomRight", coord_bottomRight.latitude, coord_bottomRight.longitude)
            console.log("bearing", map.bearing)
            console.log("center", coord_center.latitude, coord_center.longitude)

            return coord_topLeft.distanceTo(coord_bottomRight) * Math.cos(Math.PI / 4.0)
        }
        return -1
    }

    function recenter() {
        if (map && map.center) {
            coordinate = map.center
        }
    }

    function requestProcess() {
        processRequested(polygonList(), gridRows, gridColumns)
    }

    function polygonList() {
        if (!map) {
            return []
        }

        var polygonsList = []
        var point_topLeft     = Qt.point(root.x, root.y)
        var point_bottomRight = Qt.point(root.x + sourceItem.width,
                                         root.y + sourceItem.height)

        var hor = (point_bottomRight.x - point_topLeft.x) / root.gridColumns
        var ver = (point_bottomRight.y - point_topLeft.y) / root.gridRows

        for (var row = 0; row < root.gridRows; ++row) {
            for (var column = 0; column < root.gridColumns; ++column) {
                var tl = map.toCoordinate(Qt.point(
                    point_topLeft.x +  column      * hor,
                    point_topLeft.y +  row         * ver))
                var tr = map.toCoordinate(Qt.point(
                    point_topLeft.x + (column + 1) * hor,
                    point_topLeft.y +  row         * ver))
                var br = map.toCoordinate(Qt.point(
                    point_topLeft.x + (column + 1) * hor,
                    point_topLeft.y + (row + 1)    * ver))
                var bl = map.toCoordinate(Qt.point(
                    point_topLeft.x +  column      * hor,
                    point_topLeft.y + (row + 1)    * ver))

                polygonsList.push([tl, tr, br, bl, tl])
            }
        }
        return polygonsList
    }

    function setCellResult(index, result, isProcess) {
        var cell = gridRepeater.itemAt(index)
        if (!cell) return
        cell.cellLabel.text = result
        cell.cellStack.currentIndex = isProcess ? 1 : 0
    }

    MouseArea {
        id: mouseAreaDrag
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.SizeAllCursor

        enabled: root.overlayEnabled

        property point pressScreenPoint
        property var   pressCoordinate
        property bool  dragging: false

        onPressed: function(mouse) {
            if (!root.mapView || !root.map) return

            pressScreenPoint = mapToItem(root.mapView, mouse.x, mouse.y)
            pressCoordinate  = root.coordinate
            dragging = true
            mouse.accepted = true
        }

        onPositionChanged: function(mouse) {
            if (!dragging || !root.mapView || !root.map) return

            var curScreenPoint = mapToItem(root.mapView, mouse.x, mouse.y)
            var pressMapPt     = mapToItem(root.map, pressScreenPoint.x, pressScreenPoint.y)
            var curMapPt       = mapToItem(root.map, curScreenPoint.x,   curScreenPoint.y)

            var cPress = root.map.toCoordinate(pressMapPt, false)
            var cCur   = root.map.toCoordinate(curMapPt,   false)

            if (cPress && cCur) {
                var dLon = cCur.longitude - cPress.longitude
                var dLat = cCur.latitude  - cPress.latitude

                root.coordinate = QtPositioning.coordinate(
                    pressCoordinate.latitude  + dLat,
                    pressCoordinate.longitude + dLon)
            }
        }

        onReleased: dragging = false
        onCanceled: dragging = false
    }

    sourceItem: Rectangle {
        id: toolRectangle
        width: root.gridSize
        height: width
        color: Qt.rgba(255, 255, 255, 0.5)

        GridLayout {
            id: toolGridLayout
            anchors.fill: parent
            rows: root.gridRows
            columns: root.gridColumns
            rowSpacing: 0
            columnSpacing: 0

            Repeater {
                id: gridRepeater
                model: toolGridLayout.rows * toolGridLayout.columns

                delegate: Rectangle {
                    id: cellDelegate

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Qt.rgba(255, 255, 255, 0.0)
                    border.color: "black"
                    border.width: 1

                    property int  cellIndex: index
                    property alias cellLabel: cellLabel
                    property alias cellStack: cellStack

                    StackLayout {
                        id: cellStack
                        anchors.fill: parent
                        currentIndex: 0

                        Rectangle {
                            Layout.alignment: Qt.AlignCenter
                            color: Qt.rgba(255, 255, 255, 0.0)

                            Label {
                                id: cellLabel
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
                            running: root.overlayEnabled
                        }
                    }
                }
            }
        }

        ColumnLayout {
            anchors.left: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 5
            spacing: 5

            RowLayout {
                Button {
                    id: decreaseButton
                    icon.source: "qrc:/assets/icons/overlay_decrease.svg"
                    icon.color: "black"
                    icon.width: 24
                    icon.height: 24
                    display: AbstractButton.IconOnly
                    implicitWidth: 32
                    implicitHeight: 32
                    padding: 0

                    onClicked: {
                        if (root.gridRows > 1) {
                            root.gridRows = root.gridRows - 1
                            root.gridColumns = root.gridRows
                        }
                    }
                }
                Button {
                    id: increaseButton
                    icon.source: "qrc:/assets/icons/overlay_increase.svg"
                    icon.color: "black"
                    icon.width: 24
                    icon.height: 24
                    display: AbstractButton.IconOnly
                    implicitWidth: 32
                    implicitHeight: 32
                    padding: 0

                    onClicked: {
                        root.gridRows = root.gridRows + 1
                        root.gridColumns = root.gridRows
                    }
                }
            }

            RowLayout {
                Label {
                    id: labelNumber
                    padding: 5
                    text: `${root.gridRows}x${root.gridColumns}`
                    color: "white"
                    background: Rectangle {
                        color: "black"
                        radius: 5
                    }
                }

                Label {
                    padding: 5
                    text: root.distance().toFixed(1)
                    color: "white"
                    background: Rectangle {
                        color: "black"
                        radius: 5
                    }
                }

                Label {
                    padding: 5
                    text: (root.distance() / root.gridRows).toFixed(1)
                    color: "white"
                    background: Rectangle {
                        color: "black"
                        radius: 5
                    }
                }
            }
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
                id: resizeMouseArea
                preventStealing: true
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor

                onPositionChanged: {
                    if (pressed) {
                        var s = Math.max(resizeMouseArea.mouseX - width / 2,
                                         resizeMouseArea.mouseY - height / 2)
                        root.gridSize += s
                    }
                }
            }
        }
    }
}

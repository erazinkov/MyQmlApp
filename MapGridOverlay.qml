import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation

MapQuickItem {
    id: root

    property Map map
    property var startLocation
    property bool checked: true

    property Item dragArea: parent
    readonly property real cellDistance: distance() >= 0 && toolGridLayout.rows > 0
                                         ? distance() / toolGridLayout.rows
                                         : -1

    coordinate: startLocation.coordinate
    anchorPoint: Qt.point(sourceItem.width / 2, sourceItem.height / 2)
    visible: root.checked

    sourceItem: Rectangle {
        id: toolRectangle
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

                    StackLayout {
                        anchors.fill: parent
                        currentIndex: 0

                        Rectangle {
                            color: Qt.rgba(255, 255, 255, 0.0)
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

                        BusyIndicator {
//                            anchors.centerIn: parent
                            running: true
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
                    implicitWidth: labelNumber.height
                    implicitHeight: labelNumber.height
                    text: "+"
                    onClicked: {
                        toolGridLayout.rows    += 1
                        toolGridLayout.columns  = toolGridLayout.rows
                    }
                }
                Button {
                    implicitWidth: labelNumber.height
                    implicitHeight: labelNumber.height
                    text: "-"
                    onClicked: {
                        if (toolGridLayout.rows > 1) {
                            toolGridLayout.rows    -= 1
                            toolGridLayout.columns  = toolGridLayout.rows
                        }
                    }
                }
            }

            RowLayout {
                Label {
                    id: labelNumber
                    padding: 5
                    text: `${toolGridLayout.rows}x${toolGridLayout.columns}`
                    color: "white"
                    background: Rectangle { color: "black"; radius: 5 }
                }
                Label {
                    padding: 5
                    text: root.distance() >= 0 ? root.distance().toFixed(1) : "—"
                    color: "white"
                    background: Rectangle { color: "black"; radius: 5 }
                }
                Label {
                    padding: 5
                    text: root.cellDistance >= 0 ? root.cellDistance.toFixed(1) : "—"
                    color: "white"
                    background: Rectangle { color: "black"; radius: 5 }
                }
            }
        }

        DragHandler {
            target: root
            xAxis.minimum: toolRectangle.border.width
            xAxis.maximum: root.dragArea ? root.dragArea.width  - toolRectangle.width  - toolRectangle.border.width : Infinity
            yAxis.minimum: toolRectangle.border.width
            yAxis.maximum: root.dragArea ? root.dragArea.height - toolRectangle.height - toolRectangle.border.width : Infinity
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
                onPressedChanged: dragHandler.enabled = !pressed

                onPositionChanged: {
                    if (pressed) {
                        var s = Math.max(mouseAreaResize.mouseX - width / 2,
                                         mouseAreaResize.mouseY - height / 2)
                        toolRectangle.width += s
                    }
                }
            }
        }
    }

    function distance() {
        if (!map || !startLocation) return -1
        var point_topLeft     = Qt.point(root.x, root.y)
        var point_bottomRight = Qt.point(root.x + toolRectangle.width, root.y + toolRectangle.height)
        var coord_topLeft     = map.toCoordinate(point_topLeft)
        var coord_bottomRight = map.toCoordinate(point_bottomRight)
        if (coord_topLeft && coord_bottomRight) {
            return coord_topLeft.distanceTo(coord_bottomRight) * Math.cos(Math.PI / 4.0)
        }
        return -1
    }
}

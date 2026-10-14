import QtQuick
import QtQuick.Shapes

Rectangle {
    id: root
    width: 60
    height: 60
    radius: 8
    color: "black"

    property int stateIndex: 0
    readonly property var stateRotations: [0, 45]

    signal buttonStateChanged(int newIndex)

    Item {
        id: arrowContainer
        anchors.fill: parent
        anchors.margins: 10
        rotation: root.stateRotations[root.stateIndex]
        transformOrigin: Item.Center

        Behavior on rotation {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        // Circumradius so the triangle stays inside at any rotation
        readonly property real r: Math.min(width, height) / 2

        // Center of the container
        readonly property real cx: width / 2
        readonly property real cy: height / 2

        // Precomputed vertex positions (equilateral triangle, pointing up)
        readonly property real v1x: cx
        readonly property real v1y: cy - r

        readonly property real v2x: cx + r * Math.cos(Math.PI / 6)
        readonly property real v2y: cy + r * Math.sin(Math.PI / 6)

        readonly property real v3x: cx + r * Math.cos(5 * Math.PI / 6)
        readonly property real v3y: cy + r * Math.sin(5 * Math.PI / 6)

        Shape {
            id: arrow
            anchors.fill: parent
            antialiasing: true


            ShapePath {
                fillColor: "white"
                strokeColor: "white"
                strokeWidth: 0

                startX: arrowContainer.v1x
                startY: arrowContainer.v1y

                PathLine { x: arrowContainer.v2x; y: arrowContainer.v2y }
                PathLine { x: arrowContainer.v3x; y: arrowContainer.v3y }
                PathLine { x: arrowContainer.v1x; y: arrowContainer.v1y }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.stateIndex = (root.stateIndex + 1) % root.stateRotations.length
            root.buttonStateChanged(root.stateIndex)
        }
    }
}

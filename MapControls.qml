import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.alignment: Qt.AlignRight
    property alias placesButton: placesButton
    property var map: null

    signal mapTypeClicked()
    signal placesClicked()
    signal myLocationClicked()
    signal nearMeToggled(bool checked)

    spacing: 5

    Button {
        id: mapTypeButton
        Layout.alignment: Qt.AlignRight
        icon.source: "qrc:/assets/icons/map.svg"
        icon.color: "black"
        icon.width: 24
        icon.height: 24
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onClicked: root.mapTypeClicked()
    }

    Button {
        id: placesButton
        Layout.alignment: Qt.AlignRight
        icon.source: "qrc:/assets/icons/places.svg"
        icon.color: "black"
        icon.width: 24
        icon.height: 24
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onClicked: root.placesClicked()
    }

    RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: 5

        Button {
            id: rightRotationButton
            icon.source: "qrc:/assets/icons/rotate_right.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            autoRepeat: true
            autoRepeatDelay: 500
            autoRepeatInterval: 100

            enabled: root.map !== null
            onClicked: root.map.bearing = (root.map.bearing + 1) % 360
        }

        Button {
            id: leftRotationButton
            icon.source: "qrc:/assets/icons/rotate_left.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            autoRepeat: true
            autoRepeatDelay: 500
            autoRepeatInterval: 100

            enabled: root.map !== null
            onClicked: root.map.bearing = (root.map.bearing - 1 + 360) % 360
        }

        Button {
            id: northButton
            implicitWidth: 32
            implicitHeight: 32
            enabled: root.map !== null

            contentItem: Image {
                source: "qrc:/assets/icons/north.svg"
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit
                rotation: root.map ? -root.map.bearing : 0
                transformOrigin: Item.Center
            }

            onClicked: root.map.bearing = 0
        }
    }

    RowLayout {
        id: tiltControls
        Layout.alignment: Qt.AlignRight
        spacing: 5

        readonly property real tiltStep: 10
        readonly property real minTilt: 0
        readonly property real maxTilt: 60

        Button {
            id: tiltDownButton
            icon.source: "qrc:/assets/icons/tilt_arrow_down.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            enabled: root.map !== null && root.map.tilt > tiltControls.minTilt
            onClicked: {
                root.map.tilt = Math.max(tiltControls.minTilt, root.map.tilt - tiltControls.tiltStep)
            }
        }

        Button {
            id: tiltUpButton
            icon.source: "qrc:/assets/icons/tilt_arrow_up.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            enabled: root.map !== null && root.map.tilt < tiltControls.maxTilt
            onClicked: {
                root.map.tilt = Math.min(tiltControls.maxTilt, root.map.tilt + tiltControls.tiltStep)
            }
        }
    }

    RowLayout {
        id: zoomControls
        Layout.alignment: Qt.AlignRight
        spacing: 5

        Button {
            id: zoomInButton
            icon.source: "qrc:/assets/icons/zoom_in.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            enabled: root.map !== null
            onClicked: root.map.zoomLevel = Math.min(root.map.maximumZoomLevel,
                                                    root.map.zoomLevel + 1)
        }

        Button {
            id: zoomOutButton
            icon.source: "qrc:/assets/icons/zoom_out.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            enabled: root.map !== null
            onClicked: root.map.zoomLevel = Math.max(root.map.minimumZoomLevel,
                                                    root.map.zoomLevel - 1)
        }
    }

    Button {
        id: nearMeButton
        Layout.alignment: Qt.AlignRight
        checkable: true
        checked: false
        icon.source: checked ? "qrc:/assets/icons/near_me.svg"
                             : "qrc:/assets/icons/near_me_disabled.svg"
        icon.color: "black"
        icon.width: 24
        icon.height: 24
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onToggled: root.nearMeToggled(checked)
    }

    Button {
        id: myLocationButton
        Layout.alignment: Qt.AlignRight
        icon.source: "qrc:/assets/icons/my_location.svg"
        icon.color: "black"
        icon.width: 24
        icon.height: 24
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onClicked: root.myLocationClicked()
    }
}

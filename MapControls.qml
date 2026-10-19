import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

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
        icon.source: "qrc:/assets/icons/map.png"
        icon.color: "black"
        icon.width: 32
        icon.height: 32
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onClicked: root.mapTypeClicked()
    }

    Button {
        id: placesButton
        Layout.alignment: Qt.AlignRight
        icon.source: "qrc:/assets/icons/places.png"
        icon.color: "black"
        icon.width: 32
        icon.height: 32
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

            enabled: root.map !== null
            onClicked: root.map.bearing = (root.map.bearing + 1) % 360
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

            enabled: root.map !== null
            onClicked: root.map.bearing = (root.map.bearing - 1 + 360) % 360
        }

        Button {
            id: northButton
            implicitWidth: 32
            implicitHeight: 32
            enabled: root.map !== null

            contentItem: Image {
                source: "qrc:/assets/icons/north.png"
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit
                rotation: root.map ? -root.map.bearing : 0
                transformOrigin: Item.Center
            }

            onClicked: root.map.bearing = 0
        }
    }

    Button {
        id: nearMeButton
        Layout.alignment: Qt.AlignRight
        checkable: true
        checked: false
        icon.source: checked ? "qrc:/assets/icons/near_me.png"
                             : "qrc:/assets/icons/near_me_disabled.png"
        icon.color: "black"
        icon.width: 32
        icon.height: 32
        display: AbstractButton.IconOnly
        implicitWidth: 32
        implicitHeight: 32
        padding: 0

        onToggled: root.nearMeToggled(checked)
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

        onClicked: root.myLocationClicked()
    }
}

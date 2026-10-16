import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    readonly property alias updatePathChecked: updatePathButton.checked

    signal resetPathClicked()

    spacing: 5

    RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: 4

        Button {
            id: updatePathButton
            Layout.alignment: Qt.AlignRight
            checkable: true
            checked: false
            icon.source: checked ? "qrc:/assets/icons/conversion_path_on.png"
                                 : "qrc:/assets/icons/conversion_path_off.png"
            icon.color: "black"
            icon.width: 32
            icon.height: 32
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0
        }

        Button {
            id: resetPathButton
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

            onClicked: root.resetPathClicked()
        }

    }
}

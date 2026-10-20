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
        spacing: 5

        Button {
            id: resetPathButton
            icon.source: "qrc:/assets/icons/refresh.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            onClicked: root.resetPathClicked()
        }
        Button {
            id: updatePathButton
            Layout.alignment: Qt.AlignRight
            checkable: true
            checked: false
            icon.source: checked ? "qrc:/assets/icons/conversion_path.svg"
                                 : "qrc:/assets/icons/conversion_path_off.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0
        }

    }
}

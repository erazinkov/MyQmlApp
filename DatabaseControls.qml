import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root

    property bool connectionState: false
//    readonly property alias uploadDatabaseChecked: uploadDatabaseButton.checked

    signal searchDatabaseClicked()
    signal connectDatabaseClicked()
    signal disconnectDatabaseClicked()
    signal settingsDatabaseClicked()
    signal uploadDatabaseToggled(bool checked)

    spacing: 5

    RowLayout {
        Layout.alignment: Qt.AlignRight
        spacing: 5

        Button {
            id: uploadDatabaseButton
            visible: connectionState
            enabled: connectionState
            checkable: true
            checked: false
            icon.source: "qrc:/assets/icons/database_upload.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            onCheckedChanged: root.uploadDatabaseToggled(checked)

        }
        Button {
            id: searchDatabaseButton
            visible: connectionState
            enabled: connectionState
            icon.source: "qrc:/assets/icons/database_search.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            onClicked: root.searchDatabaseClicked()
        }
        Button {
            id: connectDatabaseButton
            icon.source: connectionState ? "qrc:/assets/icons/database.svg"
                                         : "qrc:/assets/icons/database_off.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            onClicked: connectionState ? root.disconnectDatabaseClicked() : root.connectDatabaseClicked()
        }

        Button {
            id: settingsDatabaseButton
            icon.source: "qrc:/assets/icons/settings.svg"
            icon.color: "black"
            icon.width: 24
            icon.height: 24
            display: AbstractButton.IconOnly
            implicitWidth: 32
            implicitHeight: 32
            padding: 0

            onClicked: root.settingsDatabaseClicked()
        }

    }
}

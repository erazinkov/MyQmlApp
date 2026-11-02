import QtQuick 2.0
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    title: qsTr("Database Search Settings")
    modal: true
    anchors.centerIn: parent
    focus: true

    property date fromDate: new Date(2025, 5, 15)
    property date toDate: new Date(2025, 5, 16)
    property string activeSelector: "to"

    property int displayYear: fromDate.getFullYear()
    property int displayMonth: fromDate.getMonth()

    ColumnLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 5
            Button {
                Layout.fillWidth: true
                text: Qt.formatDate(root.fromDate, "yyyy-MM-dd")
                checkable: true
                checked: root.activeSelector === "from"
                onClicked: root.activeSelector = "from"
            }

            Button {
                Layout.fillWidth: true
                text: Qt.formatDate(root.toDate, "yyyy-MM-dd")
                checkable: true
                checked: root.activeSelector === "to"
                onClicked: root.activeSelector = "to"
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            RoundButton {
                id: previousMonth
                icon.source: "qrc:/assets/icons/chevron_left.svg"
                icon.color: "black"
                icon.width: 24
                icon.height: 24
                display: AbstractButton.IconOnly
                padding: 0

                onClicked: {
                    if (root.displayMonth === 0) {
                        root.displayMonth = 11
                        root.displayYear--
                    } else {
                        root.displayMonth--
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(new Date(root.displayYear, root.displayMonth, 1), "MMMM")
                font.bold: true
            }

            RoundButton {
                id: nextMonth
                icon.source: "qrc:/assets/icons/chevron_right.svg"
                icon.color: "black"
                icon.width: 24
                icon.height: 24
                display: AbstractButton.IconOnly
                padding: 0

                onClicked: {
                    if (root.displayMonth === 11) {
                        root.displayMonth = 0
                        root.displayYear++
                    } else {
                        root.displayMonth++
                    }
                }
            }

            SpinBox {
                id: yearSpinBox
                from: new Date().getFullYear() - 1
                to: new Date().getFullYear() + 1
                value: root.displayYear
                editable: true
                onValueModified: root.displayYear = value
            }
        }

        DayOfWeekRow {
            locale: monthGrid.locale
            Layout.column: 1
            Layout.fillWidth: true
        }

        MonthGrid {
            id: monthGrid
            month: root.displayMonth
            year: root.displayYear
            locale: Qt.locale("en_US")

            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: Rectangle {
                implicitWidth: dayRectangle.implicitHeight + 5
                implicitHeight: dayRectangle.implicitHeight + 5
                color: "transparent"

                readonly property date delegateDate: new Date(model.year, model.month, model.day)
                readonly property bool isFrom: model.year === root.fromDate.getFullYear()
                                        && model.month === root.fromDate.getMonth()
                                        && model.day === root.fromDate.getDate()
                readonly property bool isTo: model.year === root.toDate.getFullYear()
                                      && model.month === root.toDate.getMonth()
                                      && model.day === root.toDate.getDate()
                readonly property bool inRange: {
                    const d = new Date(model.year, model.month, model.day)
                    return d >= root.fromDate && d <= root.toDate
                }

                Rectangle {
                    id: dayRectangle
                    implicitWidth: dayText.implicitHeight + 15
                    implicitHeight: dayText.implicitHeight + 15
                    radius: dayText.implicitHeight + 5
                    color: {
                        if (isFrom || isTo) {
                            return "black"
                        }
                        if (inRange) {
                            return "gray"
                        }
                        return "transparent"
                    }

                    Text {
                        id: dayText
                        anchors.centerIn: parent
                        text: model.day
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: {
                            if (isFrom || isTo) {
                                return "white"
                            }
                            if (model.month !== monthGrid.month) {
                                return "black"
                            }
                            return "black"
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const picked = new Date(model.year, model.month, model.day)
                        if (root.activeSelector === "from") {
                            root.fromDate = picked
                            if (root.toDate < root.fromDate) {
                                root.toDate = root.fromDate
                            }
                            root.activeSelector = "to"
                        } else {
                            if (picked < root.fromDate) {
                                root.fromDate = picked
                            } else {
                                root.toDate = picked
                            }
                        }
                    }
                }
            }
        }
    }
    footer: DialogButtonBox {
        Button {
           text: qsTr("Cancel")
           DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
           onClicked: {
               root.close()
           }
        }
        Button {
           text: qsTr("Ok")
           DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
           onClicked: {
               root.accept()
           }
        }
    }
}


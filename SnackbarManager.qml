import QtQuick

Item {
    id: root

    property int defaultTimeout: 5000
    property int spacing: 5
    property int maxVisible: 5

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    Column {
        id: stack
        spacing: root.spacing
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    function show(msg, timeout) {
        // evict oldest if over cap — children list is now accurate
        while (maxVisible > 0 && stack.children.length >= maxVisible) {
            stack.children[0].dismiss()
        }

        const comp = Qt.createComponent("Snackbar.qml")
        if (comp.status !== Component.Ready) {
            console.error("SnackBar not ready:", comp.errorString())
            return
        }

        const bar = comp.createObject(stack, {
            message: msg,
            timeout: timeout === undefined ? defaultTimeout : timeout
        })
        if (!bar) {
            console.error("createObject failed")
            return
        }

        bar.open()
    }
}

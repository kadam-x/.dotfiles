import qs
import QtQuick

Rectangle {
    id: root

    property bool open: false
    property var now: new Date()
    signal clicked()

    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"
    implicitWidth: clockText.implicitWidth + 14
    implicitHeight: 24
    radius: 0

    Text {
        id: clockText
        anchors.centerIn: parent
        color: Config.colors.fg
        font.family: Config.bar.fontFamily
        font.pixelSize: 20
        font.bold: false
        text: Qt.formatDateTime(root.now, "HH:mm")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}

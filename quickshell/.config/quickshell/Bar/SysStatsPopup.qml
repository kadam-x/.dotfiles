import qs
import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var anchorWindow
    property real cpuPct: 0
    property real ramPct: 0
    property real ramUsedGB: 0
    property real ramTotalGB: 0
    property real diskUsedGB: 0
    property real diskTotalGB: 0
    property real diskFreeGB: 0
    property var anchorChip
    property bool open: false

    anchor.window: anchorWindow
    anchor.rect.x: {
        const gp = anchorChip.mapToItem(null, 0, 0);
        return gp.x + anchorChip.width / 2 - implicitWidth / 2;
    }
    anchor.rect.y: anchorWindow.height
    implicitWidth: sysColumn.implicitWidth + 24
    implicitHeight: sysColumn.implicitHeight + 16
    visible: open
    color: Config.colors.bg

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Config.colors.accent
        border.width: Config.borders.width
    }

    Column {
        id: sysColumn
        anchors.centerIn: parent
        spacing: 6

        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "CPU  " + root.cpuPct + "%"
        }
        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "RAM  " + root.ramUsedGB.toFixed(1) + " / " + root.ramTotalGB.toFixed(1) + " GB (" + root.ramPct + "%)"
        }
        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "Disk " + root.diskUsedGB.toFixed(0) + " / " + root.diskTotalGB.toFixed(0) + " GB (" + root.diskFreeGB.toFixed(0) + "G free)"
        }
    }
}

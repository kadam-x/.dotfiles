import qs
import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var anchorWindow
    property var anchorChip
    property string netType: "none"
    property string netSsid: ""
    property int netStrength: 0
    property bool open: false

    anchor.window: anchorWindow
    anchor.rect.x: {
        const gp = anchorChip.mapToItem(null, 0, 0);
        return gp.x + anchorChip.width / 2 - implicitWidth / 2;
    }
    anchor.rect.y: anchorWindow.height
    implicitWidth: netColumn.implicitWidth + 24
    implicitHeight: netColumn.implicitHeight + 16
    visible: open
    color: Config.colors.bg

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Config.colors.accent
        border.width: Config.borders.width
    }

    Column {
        id: netColumn
        anchors.centerIn: parent
        spacing: 6

        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "Status  " + (root.netType === "ethernet" ? "Ethernet"
                : root.netType === "wifi" ? "Wi-Fi"
                : "Offline")
        }
        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            visible: root.netType === "wifi"
            text: "Network  " + (root.netSsid.length > 0 ? root.netSsid : "Wi-Fi")
        }
        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            visible: root.netType === "wifi"
            text: "Signal  " + root.netStrength + "%"
        }
    }
}

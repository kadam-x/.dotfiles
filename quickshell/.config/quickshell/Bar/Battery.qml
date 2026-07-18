import qs
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower

Rectangle {
    id: root

    visible: UPower.displayDevice && UPower.displayDevice.isLaptopBattery
    color: "transparent"
    implicitWidth: batteryRow.implicitWidth + 14
    implicitHeight: 24
    radius: 0

    readonly property var device: UPower.displayDevice
    readonly property int pct: device ? Math.round(device.percentage * 100) : 0
    readonly property bool charging: device && device.state === UPowerDeviceState.Charging
    readonly property bool full: device && device.state === UPowerDeviceState.FullyCharged
    readonly property bool warning: !charging && pct < 30 && pct >= 15
    readonly property bool critical: !charging && pct < 15

    readonly property string iconName: {
        if (charging) return "battery-good-charging";
        if (full) return "battery-full-charged";
        if (pct >= 80) return "battery-full";
        if (pct >= 55) return "battery-good";
        if (pct >= 30) return "battery-low";
        return "battery-caution";
    }

    Row {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6

        IconImage {
            implicitSize: 16
            anchors.verticalCenter: parent.verticalCenter
            source: Quickshell.iconPath(root.iconName, true)
        }

        Text {
            font.family: Config.bar.fontFamily
            font.pixelSize: 20
            font.bold: false
            color: root.critical ? "#f87171"
                 : root.warning ? "#fbbf24"
                 : root.charging ? "#86efac"
                 : Config.colors.fg
            text: root.pct + "%"
        }
    }

    SequentialAnimation on color {
        running: root.critical
        loops: Animation.Infinite
        ColorAnimation { from: "transparent"; to: Qt.rgba(0.97, 0.44, 0.44, 0.16); duration: 600 }
        ColorAnimation { from: Qt.rgba(0.97, 0.44, 0.44, 0.16); to: "transparent"; duration: 600 }
    }
}

import qs
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root

    property var anchorWindow
    property var anchorChip
    property string netType: "none"
    property string netSsid: ""
    property int netStrength: 0
    property bool hasWifi: false
    property string wifiDev: ""
    property string ethDev: ""
    property string ethIp: ""
    property int ethSpeedMbps: 0
    property bool open: false

    property var netScan: []
    property string pendingSsid: ""

    anchor.window: anchorWindow
    anchor.rect.x: {
        const gp = anchorChip.mapToItem(null, 0, 0);
        return gp.x + anchorChip.width / 2 - implicitWidth / 2;
    }
    anchor.rect.y: anchorWindow.height
    implicitWidth: 260
    implicitHeight: netColumn.implicitHeight + 24
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
        anchors.fill: parent
        anchors.margins: 12
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
            visible: root.netType === "ethernet"
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            text: "IP  " + (root.ethIp.length > 0 ? root.ethIp : "—")
        }
        Text {
            visible: root.netType === "ethernet"
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            text: "Link  " + (root.ethSpeedMbps > 0 ? (root.ethSpeedMbps + " Mbps") : "—")
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

        Rectangle {
            width: netColumn.width
            height: 1
            color: Config.colors.accent
            visible: root.hasWifi
        }

        Text {
            visible: root.hasWifi
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "Wi-Fi Networks"
        }

        Repeater {
            model: root.netScan
            delegate: Rectangle {
                id: netRow
                required property var modelData
                readonly property bool isInUse: modelData.inUse
                readonly property bool isPending: root.pendingSsid === modelData.ssid
                readonly property bool secured: modelData.security.length > 0

                width: netColumn.width
                height: netRow.isPending ? 54 : 28
                color: netRow.isPending || netHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"

                MouseArea {
                    id: netHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (netRow.isInUse) {
                            root.pendingSsid = "";
                            disconnectProc.running = true;
                        } else if (netRow.secured) {
                            root.pendingSsid = netRow.isPending ? "" : netRow.modelData.ssid;
                        } else {
                            root.pendingSsid = "";
                            connectProc.run(netRow.modelData.ssid, "");
                        }
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    spacing: 4

                    RowLayout {
                        width: parent.width
                        height: 20
                        spacing: 6

                        Text {
                            text: netRow.isInUse ? "●" : "○"
                            color: Config.colors.fg
                            font.pixelSize: 12
                        }
                        Text {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            text: netRow.modelData.ssid
                            color: Config.colors.fg
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 13
                        }
                        Text {
                            text: netRow.modelData.signal + "%"
                            color: Config.colors.fg
                            font.pixelSize: 12
                        }
                        Text {
                            visible: netRow.secured
                            text: netRow.modelData.security
                            color: Config.colors.muted
                            font.pixelSize: 12
                        }
                    }

                    Row {
                        visible: netRow.isPending && netRow.secured
                        width: parent.width
                        spacing: 6

                        TextField {
                            id: passField
                            width: parent.width - connectBtn.width - 6
                            height: 22
                            echoMode: TextInput.Password
                            placeholderText: "password"
                            placeholderTextColor: Config.colors.muted
                            color: Config.colors.fg
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 12
                            background: Rectangle {
                                color: Config.colors.bg
                                border.color: Config.colors.accent
                                border.width: 1
                            }
                        }

                        Text {
                            id: connectBtn
                            text: "connect"
                            color: Config.colors.fg
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                onClicked: connectProc.run(netRow.modelData.ssid, passField.text)
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: root.open && root.hasWifi
        repeat: true
        triggeredOnStart: true
        onTriggered: scanProc.running = true
    }

    Timer {
        interval: 5000
        running: root.open && root.netType === "ethernet" && root.ethDev.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: ethInfoProc.run(root.ethDev)
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                for (const line of text.trim().split("\n")) {
                    const p = line.split(":");
                    const ssid = p[1] || "";
                    if (ssid.length === 0) continue;
                    list.push({
                        ssid: ssid,
                        signal: parseInt(p[2], 10) || 0,
                        security: p[3] || "",
                        inUse: p[0] === "*"
                    });
                }
                root.netScan = list;
            }
        }
    }

    Process {
        id: ethInfoProc
        property string dev: ""
        function run(d) {
            dev = d;
            running = true;
        }
        command: ["sh", "-c",
            "cat /sys/class/net/'" + root.esc(dev) + "'/speed 2>/dev/null; echo ---; "
            + "nmcli -t -f IP4.ADDRESS device show '" + root.esc(dev) + "' 2>/dev/null | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("---");
                const speed = parseInt((parts[0] || "").trim(), 10);
                root.ethSpeedMbps = isNaN(speed) ? 0 : speed;
                const ipLine = (parts[1] || "").trim();
                const ip = ipLine.split(":")[1] || "";
                root.ethIp = ip.split("/")[0] || "";
            }
        }
    }

    Process {
        id: connectProc
        property string targetSsid: ""
        property string targetPass: ""
        function run(ssid, pass) {
            targetSsid = ssid;
            targetPass = pass;
            running = true;
        }
        command: ["sh", "-c", "nmcli dev wifi connect '" + root.esc(targetSsid) + "'"
            + (targetPass.length > 0 ? " password '" + root.esc(targetPass) + "'" : "")]
        stdout: StdioCollector {
            onStreamFinished: {
                root.pendingSsid = "";
                scanProc.running = true;
            }
        }
    }

    Process {
        id: disconnectProc
        command: ["nmcli", "dev", "disconnect", root.wifiDev]
        stdout: StdioCollector {
            onStreamFinished: scanProc.running = true
        }
    }

    function esc(s) {
        return s.replace(/'/g, "'\\''");
    }
}

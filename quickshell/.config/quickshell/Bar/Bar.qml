import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.bar.height
    color: Config.colors.bg

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property string netType: "none"
    property string netSsid: ""
    property int netStrength: 0

    property real cpuPct: 0
    property real ramPct: 0
    property real ramUsedGB: 0
    property real ramTotalGB: 0
    property real diskUsedGB: 0
    property real diskFreeGB: 0
    property real diskTotalGB: 0
    property real diskPct: diskTotalGB > 0 ? Math.round((diskUsedGB / diskTotalGB) * 100) : 0

    property real _prevIdle: 0
    property real _prevTotal: 0

    property var wsList: []
    property var _lastTree: null
    property var _lastWorkspaces: null

    property bool clockOpen: false
    property bool sysOpen: false
    property bool audioOpen: false

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: 12

            Workspaces {
                id: workspaces
                wsList: root.wsList
                switchWorkspace: num => switchWsProc.run(num)
            }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 2

            SystemTray {
                trayWindow: root
            }

            SysStats {
                id: sysChip
                cpuPct: root.cpuPct
                ramPct: root.ramPct
                ramUsedGB: root.ramUsedGB
                ramTotalGB: root.ramTotalGB
                diskUsedGB: root.diskUsedGB
                diskFreeGB: root.diskFreeGB
                diskTotalGB: root.diskTotalGB
                open: root.sysOpen
                onClicked: root.sysOpen = !root.sysOpen
            }

            Network {
                netType: root.netType
                netSsid: root.netSsid
                netStrength: root.netStrength
            }

            Audio {
                id: audioChip
                open: root.audioOpen
                onClicked: root.audioOpen = !root.audioOpen
            }

            Battery {}

            NotificationIndicator {}
        }
    }

    Clock {
        id: clockChip
        open: root.clockOpen
        onClicked: root.clockOpen = !root.clockOpen
    }

    PanelWindow {
        id: clickCatcher
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: "transparent"
        visible: root.clockOpen || root.sysOpen || root.audioOpen
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.clockOpen = false;
                root.sysOpen = false;
                root.audioOpen = false;
            }
        }
    }

    CalendarPopup {
        anchorWindow: root
        clockTime: clockChip.now
        open: root.clockOpen
    }

    SysStatsPopup {
        anchorWindow: root
        anchorChip: sysChip
        cpuPct: root.cpuPct
        ramPct: root.ramPct
        ramUsedGB: root.ramUsedGB
        ramTotalGB: root.ramTotalGB
        diskUsedGB: root.diskUsedGB
        diskFreeGB: root.diskFreeGB
        diskTotalGB: root.diskTotalGB
        open: root.sysOpen
    }

    AudioPopup {
        anchorWindow: root
        anchorChip: audioChip
        barWidth: root.width
        open: root.audioOpen
    }

    Process {
        id: switchWsProc
        property int targetNum: -1
        function run(num) {
            targetNum = num;
            running = true;
        }
        command: ["swaymsg", "workspace", "number", String(targetNum)]
    }

    Process {
        id: treeProc
        command: ["swaymsg", "-t", "get_tree"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._lastTree = JSON.parse(text);
                } catch (e) {
                    return;
                }
                root._rebuildWsList();
            }
        }
    }

    Process {
        id: workspacesProc
        command: ["swaymsg", "-t", "get_workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root._lastWorkspaces = JSON.parse(text);
                } catch (e) {
                    return;
                }
                root._rebuildWsList();
            }
        }
    }

    Process {
        id: subscribeProc
        command: ["swaymsg", "-t", "subscribe", "-m", "[\"window\",\"workspace\"]"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (line.trim().length > 0)
                    root.refreshWsTree();
            }
        }
        Component.onCompleted: root.refreshWsTree()
    }

    function refreshWsTree() {
        treeProc.running = true;
        workspacesProc.running = true;
    }

    function _rebuildWsList() {
        if (!_lastTree || !_lastWorkspaces) return;
        const tree = _lastTree;
        const wsData = {};
        for (const ws of _lastWorkspaces) {
            wsData[ws.num] = { name: ws.name, focused: ws.focused, urgent: ws.urgent };
        }
        const workspaces = [];
        for (const output of tree.nodes || []) {
            for (const ws of output.nodes || []) {
                if (ws.type !== "workspace") continue;
                if (ws.name && ws.name.startsWith("__")) continue;
                const info = wsData[ws.num] || {};
                const windows = [];
                for (const node of (ws.nodes || [])) {
                    windows.push({
                        app_id: node.app_id,
                        window_properties: node.window_properties
                    });
                }
                workspaces.push({
                    num: ws.num,
                    name: info.name || ws.name,
                    focused: info.focused || ws.focused,
                    urgent: info.urgent || ws.urgent,
                    windows: windows
                });
            }
        }
        root.wsList = workspaces;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netStatusProc.running = true
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            diskProc.running = true
        }
    }

    Process {
        id: netStatusProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                let foundEthernet = false, foundWifi = false, ssid = "";
                for (const line of lines) {
                    const parts = line.split(":");
                    const type = parts[0], state = parts[1], conn = parts[2];
                    if (type === "ethernet" && state === "connected")
                        foundEthernet = true;
                    if (type === "wifi" && state === "connected") {
                        foundWifi = true;
                        ssid = conn || "";
                    }
                }
                root.netType = foundEthernet ? "ethernet" : (foundWifi ? "wifi" : "none");
                root.netSsid = ssid;
                if (foundWifi)
                    wifiStrengthProc.running = true;
            }
        }
    }

    Process {
        id: wifiStrengthProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^\\*' | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const n = parseInt(text.trim(), 10);
                root.netStrength = isNaN(n) ? 0 : n;
            }
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -n1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(/\s+/).slice(1).map(Number);
                const idle = f[3] + f[4];
                const total = f.reduce((a, b) => a + b, 0);
                const dIdle = idle - root._prevIdle;
                const dTotal = total - root._prevTotal;
                if (root._prevTotal > 0 && dTotal > 0)
                    root.cpuPct = Math.round((1 - dIdle / dTotal) * 100);
                root._prevIdle = idle;
                root._prevTotal = total;
            }
        }
    }

    Process {
        id: ramProc
        command: ["sh", "-c", "free -b | awk '/^Mem:/ {print $2, $3}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(/\s+/).map(Number);
                root.ramTotalGB = p[0] / 1e9;
                root.ramUsedGB = p[1] / 1e9;
                root.ramPct = Math.round((p[1] / p[0]) * 100);
            }
        }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df -B1 / | awk 'NR==2 {print $2, $3, $4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(/\s+/).map(Number);
                root.diskTotalGB = p[0] / 1e9;
                root.diskUsedGB = p[1] / 1e9;
                root.diskFreeGB = p[2] / 1e9;
            }
        }
    }
}

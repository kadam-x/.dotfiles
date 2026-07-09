import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.bar.height
    color: Qt.rgba(Config.colors.bg.r, Config.colors.bg.g, Config.colors.bg.b, 0.75)

    readonly property string barFontFamily: Config.bar.fontFamily
    readonly property int barFontSize: 20
    readonly property bool barFontBold: false

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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: 12

            Row {
                spacing: 6

                Repeater {
                    model: Hyprland.workspaces

                    delegate: Rectangle {
                        id: wsChip

                        required property var modelData

                        readonly property bool isFocused:
                            Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

                        readonly property var wsToplevels: {
                            let out = [];
                            for (const tl of Hyprland.toplevels.values) {
                                if (tl.workspace && tl.workspace.id === modelData.id)
                                    out.push(tl);
                            }
                            return out;
                        }

                        width: wsRow.implicitWidth + 12
                        height: 30
                        radius: 0
                        color: wsChip.modelData.hasUrgent ? "#ff5454"
                             : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                        border.width: 0

                        Rectangle {
                            visible: wsChip.isFocused && !wsChip.modelData.hasUrgent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            color: Config.colors.fg
                        }
                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: wsChip.modelData.activate()
                        }

                        Row {
                            id: wsRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: wsChip.modelData.name
                                color: wsChip.modelData.hasUrgent ? "#000000" : Config.colors.fg
                                font.family: root.barFontFamily
                                font.pixelSize: root.barFontSize
                                font.bold: root.barFontBold
                            }

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Repeater {
                                    model: wsChip.wsToplevels

                                    delegate: IconImage {
                                        required property var modelData

                                        readonly property var desktopEntry:
                                            modelData.wayland ? DesktopEntries.heuristicLookup(modelData.wayland.appId) : null

                                        source: Quickshell.iconPath(desktopEntry ? desktopEntry.icon : "", true)
                                        implicitSize: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 2

            Row {
                spacing: 6
                Layout.rightMargin: 8

                Repeater {
                    model: SystemTray.items

                    delegate: IconImage {
                        id: trayIcon
                        required property var modelData

                        implicitSize: 18
                        source: modelData.icon
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                const pos = trayIcon.mapToItem(null, 0, trayIcon.height);

                                if (mouse.button === Qt.LeftButton) {
                                    if (trayIcon.modelData.onlyMenu && trayIcon.modelData.hasMenu)
                                        trayIcon.modelData.display(root, pos.x, pos.y);
                                    else
                                        trayIcon.modelData.activate();
                                } else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                                    trayIcon.modelData.display(root, pos.x, pos.y);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: sysChip
                color: hoverSys.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                implicitWidth: sysRow.implicitWidth + 14
                implicitHeight: 24
                radius: 0
                property bool open: false

                Row {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 10

                    Repeater {
                        model: [
                            { kind: "cpu", pct: root.cpuPct, warn: root.cpuPct >= 85 },
                            { kind: "ram", pct: root.ramPct, warn: root.ramPct >= 85 },
                            { kind: "disk", pct: root.diskPct, warn: root.diskFreeGB < 10 }
                        ]
                        delegate: Row {
                            required property var modelData
                            spacing: 4

                            Canvas {
                                id: statIcon
                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                property string kind: modelData.kind
                                property color strokeColor: modelData.warn ? "#f87171" : Config.colors.fg

                                onStrokeColorChanged: requestPaint()
                                Component.onCompleted: requestPaint()

                                onPaint: {
                                    const ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = strokeColor;
                                    ctx.fillStyle = strokeColor;
                                    ctx.lineWidth = 1.3;
                                    ctx.lineJoin = "round";
                                    ctx.lineCap = "round";

                                    if (kind === "cpu") {
                                        ctx.strokeRect(3.5, 3.5, 9, 9);
                                        const pins = [5, 8, 11];
                                        for (const p of pins) {
                                            ctx.beginPath(); ctx.moveTo(p, 1); ctx.lineTo(p, 3.5); ctx.stroke();
                                            ctx.beginPath(); ctx.moveTo(p, 12.5); ctx.lineTo(p, 15); ctx.stroke();
                                            ctx.beginPath(); ctx.moveTo(1, p); ctx.lineTo(3.5, p); ctx.stroke();
                                            ctx.beginPath(); ctx.moveTo(12.5, p); ctx.lineTo(15, p); ctx.stroke();
                                        }
                                    } else if (kind === "ram") {
                                        ctx.strokeRect(1.5, 4.5, 13, 8);
                                        for (const x of [4, 7, 10, 13]) {
                                            ctx.beginPath(); ctx.moveTo(x, 12.5); ctx.lineTo(x, 15); ctx.stroke();
                                        }
                                    } else {
                                        ctx.beginPath();
                                        ctx.ellipse(2.5, 2.5, 11, 3.5);
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.moveTo(2.5, 4.25);
                                        ctx.lineTo(2.5, 13);
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.moveTo(13.5, 4.25);
                                        ctx.lineTo(13.5, 13);
                                        ctx.stroke();
                                        ctx.beginPath();
                                        ctx.ellipse(2.5, 11.25, 11, 3.5);
                                        ctx.stroke();
                                    }
                                }
                            }

                            Canvas {
                                id: statBar
                                width: 6
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter

                                property real pct: modelData.pct
                                property bool warn: modelData.warn
                                property color barColor: warn ? "#f87171" : Config.colors.fg

                                onPctChanged: requestPaint()
                                onBarColorChanged: requestPaint()
                                Component.onCompleted: requestPaint()

                                onPaint: {
                                    const ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.fillStyle = barColor;
                                    ctx.globalAlpha = 0.28;
                                    ctx.fillRect(0, 0, width, height);
                                    ctx.globalAlpha = 1.0;
                                    const h = Math.max(1.5, height * Math.min(1, pct / 100));
                                    ctx.fillRect(0, height - h, width, h);
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: hoverSys
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: sysChip.open = !sysChip.open
                }
            }

            Rectangle {
                id: netChip
                color: "transparent"
                implicitWidth: netRow.implicitWidth + 14
                implicitHeight: 24
                radius: 0

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: netChip.color = Qt.rgba(1, 1, 1, 0.05)
                    onExited: netChip.color = "transparent"
                }

                Row {
                    id: netRow
                    anchors.centerIn: parent
                    spacing: 6

                    Canvas {
                        id: netIcon
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.netType !== "ethernet"

                        property color strokeColor: Config.colors.fg
                        property string netType: root.netType
                        property int netStrength: root.netStrength

                        onStrokeColorChanged: requestPaint()
                        onNetTypeChanged: requestPaint()
                        onNetStrengthChanged: requestPaint()
                        Component.onCompleted: requestPaint()

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = strokeColor;
                            ctx.fillStyle = strokeColor;
                            ctx.lineWidth = 1.3;
                            ctx.lineJoin = "round";
                            ctx.lineCap = "round";

                            ctx.globalAlpha = netType === "none" ? 0.35 : 1.0;
                            ctx.beginPath();
                            ctx.arc(8, 13, 1.3, 0, Math.PI * 2);
                            ctx.fill();

                            const tiers = netType === "wifi"
                                ? (netStrength >= 80 ? 3 : netStrength >= 55 ? 2 : netStrength >= 30 ? 1 : 0)
                                : 0;

                            for (let i = 0; i < 3; i++) {
                                const radius = 3 + i * 3;
                                ctx.globalAlpha = netType === "none" ? 0.35 : (i < tiers ? 1.0 : 0.3);
                                ctx.beginPath();
                                ctx.arc(8, 13, radius, Math.PI * 1.25, Math.PI * 1.75, false);
                                ctx.stroke();
                            }
                            ctx.globalAlpha = 1.0;

                            if (netType === "none") {
                                ctx.beginPath();
                                ctx.moveTo(2.5, 3);
                                ctx.lineTo(13.5, 13);
                                ctx.stroke();
                            }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Config.colors.fg
                        font.family: root.barFontFamily
                        font.pixelSize: root.barFontSize
                        font.bold: root.barFontBold
                        text: root.netType === "wifi" ? (root.netSsid.length > 0 ? root.netSsid : "Wi-Fi")
                            : root.netType === "ethernet" ? "eth"
                            : "Offline"
                    }
                }
            }

            Rectangle {
                id: audioChip
                color: "transparent"
                implicitWidth: audioRow.implicitWidth + 14
                implicitHeight: 24
                radius: 0

                readonly property var sink: Pipewire.defaultAudioSink
                readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
                readonly property real volumePct: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onEntered: audioChip.color = Qt.rgba(1, 1, 1, 0.05)
                    onExited: audioChip.color = "transparent"

                    onWheel: wheel => {
                        if (!audioChip.sink || !audioChip.sink.audio)
                            return;
                        const step = 0.01;
                        const delta = wheel.angleDelta.y > 0 ? step : -step;
                        audioChip.sink.audio.volume = Math.max(0, Math.min(1, audioChip.sink.audio.volume + delta));
                    }
                }

                Row {
                    id: audioRow
                    anchors.centerIn: parent
                    spacing: 6

                    Canvas {
                        id: audioIcon
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter

                        property color strokeColor: Config.colors.fg
                        property bool muted: audioChip.muted
                        property real volumePct: audioChip.volumePct

                        onStrokeColorChanged: requestPaint()
                        onMutedChanged: requestPaint()
                        onVolumePctChanged: requestPaint()
                        Component.onCompleted: requestPaint()

                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = strokeColor;
                            ctx.fillStyle = strokeColor;
                            ctx.lineWidth = 1.3;
                            ctx.lineJoin = "round";
                            ctx.lineCap = "round";

                            ctx.beginPath();
                            ctx.moveTo(2, 6);
                            ctx.lineTo(4, 6);
                            ctx.lineTo(8, 3);
                            ctx.lineTo(8, 13);
                            ctx.lineTo(4, 10);
                            ctx.lineTo(2, 10);
                            ctx.closePath();
                            ctx.fill();

                            if (muted) {
                                ctx.beginPath();
                                ctx.moveTo(2.5, 3);
                                ctx.lineTo(13.5, 13);
                                ctx.stroke();
                                return;
                            }

                            const tiers = volumePct >= 67 ? 3 : volumePct >= 34 ? 2 : volumePct > 0 ? 1 : 0;

                            for (let i = 0; i < 3; i++) {
                                const radius = 3 + i * 2.5;
                                ctx.globalAlpha = i < tiers ? 1.0 : 0.3;
                                ctx.beginPath();
                                ctx.arc(8, 8, radius, -Math.PI / 4, Math.PI / 4, false);
                                ctx.stroke();
                            }
                            ctx.globalAlpha = 1.0;
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Config.colors.fg
                        font.family: root.barFontFamily
                        font.pixelSize: root.barFontSize
                        font.bold: root.barFontBold
                        text: audioChip.muted ? "muted" : audioChip.volumePct + "%"
                    }
                }
            }

            Rectangle {
                id: batteryChip
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
                        source: Quickshell.iconPath(batteryChip.iconName, true)
                    }

                    Text {
                        font.family: root.barFontFamily
                        font.pixelSize: root.barFontSize
                        font.bold: root.barFontBold
                        color: batteryChip.critical ? "#f87171"
                             : batteryChip.warning ? "#fbbf24"
                             : batteryChip.charging ? "#86efac"
                             : Config.colors.fg
                        text: batteryChip.pct + "%"
                    }
                }

                SequentialAnimation on color {
                    running: batteryChip.critical
                    loops: Animation.Infinite
                    ColorAnimation { from: "transparent"; to: Qt.rgba(0.97, 0.44, 0.44, 0.16); duration: 600 }
                    ColorAnimation { from: Qt.rgba(0.97, 0.44, 0.44, 0.16); to: "transparent"; duration: 600 }
                }
            }

            Rectangle {
                id: historyChip
                color: hoverHist.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                implicitWidth: 28
                implicitHeight: 24
                radius: 0
                Layout.leftMargin: 4

                Canvas {
                    id: bellIcon
                    anchors.centerIn: parent
                    width: 16
                    height: 16

                    property color strokeColor: Config.colors.fg
                    onStrokeColorChanged: requestPaint()
                    Component.onCompleted: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = strokeColor;
                        ctx.fillStyle = strokeColor;
                        ctx.lineWidth = 1.3;
                        ctx.lineJoin = "round";
                        ctx.lineCap = "round";

                        ctx.beginPath();
                        ctx.moveTo(4, 10.5);
                        ctx.lineTo(4, 7);
                        ctx.arc(8, 7, 4, Math.PI, 0, false);
                        ctx.lineTo(12, 10.5);
                        ctx.closePath();
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.moveTo(3, 10.5);
                        ctx.lineTo(13, 10.5);
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.arc(8, 13, 1.3, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }

                MouseArea {
                    id: hoverHist
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: toggleHistoryProc.running = true
                }

                Process {
                    id: toggleHistoryProc
                    command: ["qs", "ipc", "call", "notifhistory", "toggle"]
                }
            }
        }
    }

    Rectangle {
        id: clockChip
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        implicitWidth: clockText.implicitWidth + 14
        implicitHeight: 24
        radius: 0

        property bool open: false

        Text {
            id: clockText
            anchors.centerIn: parent
            color: Config.colors.fg
            font.family: root.barFontFamily
            font.pixelSize: root.barFontSize
            font.bold: root.barFontBold
            text: Qt.formatDateTime(clockTimer.now, "HH:mm")
        }

        Timer {
            id: clockTimer
            property var now: new Date()
            interval: 1000
            running: true
            repeat: true
            onTriggered: now = new Date()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: clockChip.open = !clockChip.open
        }
    }

    PopupWindow {
        id: calendarPopup
        anchor.window: root
        anchor.rect.x: root.width / 2 - implicitWidth / 2
        anchor.rect.y: root.height
        implicitWidth: calColumn.implicitWidth + 16
        implicitHeight: calColumn.implicitHeight + 16
        visible: clockChip.open
        color: "#1a2230"

        HyprlandFocusGrab {
            windows: [calendarPopup]
            active: clockChip.open
            onCleared: clockChip.open = false
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#3a4a66"
            border.width: 1
        }

        Column {
            id: calColumn
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Config.colors.fg
                font.family: root.barFontFamily
                font.pixelSize: 14
                font.bold: true
                text: Qt.formatDateTime(clockTimer.now, "MMMM yyyy")
            }

            Grid {
                columns: 7
                spacing: 6

                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    delegate: Text {
                        width: 22
                        text: modelData
                        color: Config.colors.fg
                        horizontalAlignment: Text.AlignHCenter
                        font.family: root.barFontFamily
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }

            Grid {
                columns: 7
                spacing: 6

                Repeater {
                    model: {
                        const now = clockTimer.now;
                        const year = now.getFullYear();
                        const month = now.getMonth();
                        let firstWeekday = (new Date(year, month, 1)).getDay();
                        firstWeekday = (firstWeekday + 6) % 7;
                        const daysInMonth = new Date(year, month + 1, 0).getDate();
                        let days = [];
                        for (let i = 0; i < firstWeekday; i++) days.push(0);
                        for (let d = 1; d <= daysInMonth; d++) days.push(d);
                        while (days.length % 7 !== 0) days.push(0);
                        return days;
                    }

                    delegate: Rectangle {
                        id: dayCell
                        required property var modelData
                        readonly property bool isToday: modelData !== 0 && modelData === clockTimer.now.getDate()

                        width: 22
                        height: 22
                        radius: 0
                        color: isToday ? Config.colors.fg : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: dayCell.modelData === 0 ? "" : dayCell.modelData
                            color: dayCell.isToday ? Config.colors.bg : Config.colors.fg
                            font.family: root.barFontFamily
                            font.pixelSize: 11
                            font.bold: dayCell.isToday
                        }
                    }
                }
            }

            Text {
                color: Config.colors.fg
                font.family: root.barFontFamily
                font.pixelSize: 12
                text: Qt.formatDateTime(clockTimer.now, "dddd, dd MMMM yyyy")
            }
        }
    }

    PopupWindow {
        id: sysPopup
        anchor.window: root
        anchor.rect.x: sysChip.mapToItem(null, 0, 0).x + sysChip.width / 2 - implicitWidth / 2
        anchor.rect.y: root.height
        implicitWidth: sysColumn.implicitWidth + 24
        implicitHeight: sysColumn.implicitHeight + 16
        visible: sysChip.open
        color: "#1a2230"

        HyprlandFocusGrab {
            windows: [sysPopup]
            active: sysChip.open
            onCleared: sysChip.open = false
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#3a4a66"
            border.width: 1
        }

        Column {
            id: sysColumn
            anchors.centerIn: parent
            spacing: 6

            Text {
                color: Config.colors.fg
                font.family: root.barFontFamily
                font.pixelSize: 13
                font.bold: true
                text: "CPU  " + root.cpuPct + "%"
            }
            Text {
                color: Config.colors.fg
                font.family: root.barFontFamily
                font.pixelSize: 13
                font.bold: true
                text: "RAM  " + root.ramUsedGB.toFixed(1) + " / " + root.ramTotalGB.toFixed(1) + " GB (" + root.ramPct + "%)"
            }
            Text {
                color: Config.colors.fg
                font.family: root.barFontFamily
                font.pixelSize: 13
                font.bold: true
                text: "Disk " + root.diskUsedGB.toFixed(0) + " / " + root.diskTotalGB.toFixed(0) + " GB (" + root.diskFreeGB.toFixed(0) + "G free)"
            }
        }
    }
}

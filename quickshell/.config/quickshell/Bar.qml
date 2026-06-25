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

    // Bind the default sink so its audio properties (volume/muted) are
    // actually populated - PwNode's audio data stays invalid until tracked.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    // ---------------- Network state, via nmcli ----------------
    // Quickshell's native networking module is too new/sparsely documented
    // to use reliably right now, so this polls nmcli instead - a stable,
    // well documented CLI that's already a dependency of NetworkManager.
    property string netType: "none" // "wifi" | "ethernet" | "none"
    property string netSsid: ""
    property int netStrength: 0 // 0-100, wifi only

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netStatusProc.running = true
    }

    Process {
        id: netStatusProc
        // device TYPE STATE CONNECTION, colon separated, terse
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0

        // ---------------- LEFT: workspaces ----------------
        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: 12

            Row {
                spacing: 6

                Repeater {
                    // Hyprland.workspaces is an ObjectModel<HyprlandWorkspace>
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
                        // Active = white fill, urgent = red fill (matching
                        // your original waybar look), hover = faint
                        // highlight, otherwise transparent.
                        color: wsChip.modelData.hasUrgent ? "#ff5454"
                             : wsChip.isFocused ? Config.colors.fg
                             : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                        border.width: 0

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
                                // Black text when the chip has a light/colored
                                // fill (active or urgent), light text otherwise.
                                color: (wsChip.modelData.hasUrgent || wsChip.isFocused) ? "#000000" : Config.colors.fg
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
                                        required property var modelData // a HyprlandToplevel

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

        // Single spacer pushes the right-hand group to the far edge - the
        // clock used to live here too, but is now a separate item anchored
        // to root's true center (see bottom of file) instead of being
        // centered between unequal-width left/right groups.
        Item { Layout.fillWidth: true }

        // ---------------- RIGHT: tray, network, audio, battery, notif. history ----------------
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 2

            // ---- Tray (now leftmost item of the right-hand group) ----
            Row {
                spacing: 6
                Layout.rightMargin: 8

                Repeater {
                    model: SystemTray.items

                    delegate: IconImage {
                        id: trayIcon
                        required property var modelData // a SystemTrayItem

                        implicitSize: 18
                        source: modelData.icon
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton)
                                    trayIcon.modelData.activate();
                                else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu)
                                    trayIcon.modelData.display(trayIcon, 0, trayIcon.height);
                            }
                        }
                    }
                }
            }

            // ---- Network ----
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

                    // Hand-drawn instead of theme icons or nerd-font glyphs -
                    // same approach as the notification bell. Pixel-exact,
                    // never breaks if the icon theme or font changes.
                    // No icon for ethernet - text only. Wifi/offline keep
                    // the hand-drawn signal icon.
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

                            // dot
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

            // ---- Audio ----
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

                            // speaker body
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

            // ---- Battery ----
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

            // ---- Notification history toggle (rightmost) ----
            Rectangle {
                id: historyChip
                color: hoverHist.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                implicitWidth: 28
                implicitHeight: 24
                radius: 0
                Layout.leftMargin: 4

                // Drawn directly instead of relying on an icon-theme lookup
                // (which has been unreliable across themes) or an emoji
                // (which renders in full color regardless of theme). This
                // is a small monochrome bell, always exactly Config.colors.fg.
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

                        // bell body
                        ctx.beginPath();
                        ctx.moveTo(4, 11);
                        ctx.lineTo(4, 7.5);
                        ctx.arc(8, 7.5, 4, Math.PI, 0, false);
                        ctx.lineTo(12, 11);
                        ctx.stroke();

                        // bottom bar of the bell
                        ctx.beginPath();
                        ctx.moveTo(3, 11);
                        ctx.lineTo(13, 11);
                        ctx.stroke();

                        // clapper
                        ctx.beginPath();
                        ctx.arc(8, 13, 1.4, 0, Math.PI * 2);
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

    // ---------------- CENTER: clock + calendar popup ----------------
    // Deliberately NOT inside the RowLayout above. Centering it between
    // two Layout.fillWidth spacers only works if the left and right side
    // groups are equal width; since they aren't (workspaces vs.
    // tray/network/audio/battery/history), that approach visibly drifted
    // off-center. Anchoring directly to root's horizontalCenter is
    // centered against the whole bar, regardless of what's on either side.
    Rectangle {
        id: clockChip
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: "transparent"
        implicitWidth: clockText.implicitWidth + 14
        implicitHeight: 24
        radius: 0

        property bool hovered: false

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
            onEntered: clockChip.hovered = true
            onExited: closeTimer.restart()
        }
    }

    // Small grace period so moving the cursor down across the gap from the
    // clock chip into the popup doesn't slam it shut before you get there.
    Timer {
        id: closeTimer
        interval: 150
        onTriggered: clockChip.hovered = false
    }

    // A regular bar PanelWindow is only as tall as its own surface
    // (Config.bar.height) - anything drawn outside that gets clipped at
    // the Wayland layer-shell level, not by QML. PopupWindow is its own
    // separate surface anchored to root, so it can extend below the bar.
    PopupWindow {
        id: calendarPopup
        anchor.window: root
        anchor.rect.x: root.width / 2 - implicitWidth / 2
        anchor.rect.y: root.height
        implicitWidth: calColumn.implicitWidth + 16
        implicitHeight: calColumn.implicitHeight + 16
        visible: clockChip.hovered
        color: "#1a2230"

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: clockChip.hovered = true
            onExited: closeTimer.restart()
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
                        firstWeekday = (firstWeekday + 6) % 7; // Mon=0
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
}

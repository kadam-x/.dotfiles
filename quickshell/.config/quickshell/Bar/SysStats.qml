import qs
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property real cpuPct: 0
    property real ramPct: 0
    property real ramUsedGB: 0
    property real ramTotalGB: 0
    property real diskUsedGB: 0
    property real diskFreeGB: 0
    property real diskTotalGB: 0
    property real diskPct: diskTotalGB > 0 ? Math.round((diskUsedGB / diskTotalGB) * 100) : 0

    property bool open: false
    signal clicked()

    color: hoverSys.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
    implicitWidth: sysRow.implicitWidth + 14
    implicitHeight: 24
    radius: 0

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
        onClicked: root.clicked()
    }
}

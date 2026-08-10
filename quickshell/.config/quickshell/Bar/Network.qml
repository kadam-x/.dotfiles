import qs
import QtQuick

Rectangle {
    id: root

    property string netType: "none"
    property string netSsid: ""
    property int netStrength: 0

    property bool open: false
    signal clicked()

    color: "transparent"
    implicitWidth: netRow.implicitWidth + 14
    implicitHeight: 24
    radius: 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.color = Qt.rgba(1, 1, 1, 0.06)
        onExited: root.color = "transparent"
        onClicked: root.clicked()
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

                if (netType === "ethernet") {
                    ctx.strokeRect(2.5, 3, 11, 9);
                    for (const p of [5, 8, 11]) {
                        ctx.beginPath(); ctx.moveTo(p, 12); ctx.lineTo(p, 15); ctx.stroke();
                    }
                    return;
                }

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
            font.family: Config.bar.fontFamily
            font.pixelSize: 20
            font.bold: false
            text: root.netType === "wifi" ? (root.netSsid.length > 0 ? root.netSsid : "Wi-Fi")
                : root.netType === "ethernet" ? ""
                : "Offline"
        }
    }
}

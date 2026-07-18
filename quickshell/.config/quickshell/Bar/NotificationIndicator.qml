import qs
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    color: hoverHist.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
    implicitWidth: 28
    implicitHeight: 24
    radius: 0

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

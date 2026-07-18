import qs
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Rectangle {
    id: root

    property bool open: false
    signal clicked()

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volumePct: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    color: "transparent"
    implicitWidth: audioRow.implicitWidth + 14
    implicitHeight: 24
    radius: 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onEntered: root.color = Qt.rgba(1, 1, 1, 0.06)
        onExited: root.color = "transparent"

        onClicked: root.clicked()

        onWheel: wheel => {
            if (!root.sink || !root.sink.audio)
                return;
            const step = 0.01;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + delta));
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
            property bool muted: root.muted
            property real volumePct: root.volumePct

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
            font.family: Config.bar.fontFamily
            font.pixelSize: 20
            font.bold: false
            text: root.muted ? "muted" : root.volumePct + "%"
        }
    }
}

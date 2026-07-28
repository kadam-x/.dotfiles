import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

PopupWindow {
    id: root

    property var anchorWindow
    property var anchorChip
    property real barWidth: 0
    property bool open: false

    anchor.window: anchorWindow
    anchor.rect.x: {
        const gp = anchorChip.mapToItem(null, 0, 0);
        const x = gp.x + anchorChip.width / 2 - implicitWidth / 2;
        return Math.max(4, Math.min(x, barWidth - implicitWidth - 4));
    }
    anchor.rect.y: anchorWindow.height
    implicitWidth: 320
    implicitHeight: audioColumn.implicitHeight + 24
    visible: open
    color: Config.colors.bg

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Config.colors.accent
        border.width: Config.borders.width
    }

    Column {
        id: audioColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "Output Device"
        }

        Repeater {
            model: {
                const out = [];
                for (const n of Pipewire.nodes.values) {
                    if (!n.isStream && n.isSink && n.audio)
                        out.push(n);
                }
                return out;
            }

            delegate: Rectangle {
                id: sinkRow
                required property var modelData
                readonly property bool isDefault: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.id === modelData.id

                width: audioColumn.width
                height: 28
                color: sinkHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    spacing: 6

                    Text {
                        text: sinkRow.isDefault ? "●" : "○"
                        color: Config.colors.fg
                        font.pixelSize: 12
                    }
                    Text {
                        text: sinkRow.modelData.description || sinkRow.modelData.name
                        color: Config.colors.fg
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: sinkHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: setDefaultSinkProc.run(sinkRow.modelData.id)
                }
            }
        }

        Rectangle {
            width: audioColumn.width
            height: 1
            color: Config.colors.accent
        }

        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 13
            font.bold: true
            text: "Applications"
        }

        Repeater {
            model: {
                const out = [];
                for (const n of Pipewire.nodes.values) {
                    if (n.isStream && n.audio)
                        out.push(n);
                }
                return out;
            }

            delegate: Column {
                id: streamRow
                required property var modelData
                width: audioColumn.width
                spacing: 3

                Row {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: streamRow.modelData.description || streamRow.modelData.name || "App"
                        color: Config.colors.fg
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        width: parent.width - muteBtn.width - 10
                    }

                    Text {
                        id: muteBtn
                        text: streamRow.modelData.audio.muted ? "muted" : "vol"
                        color: Config.colors.fg
                        font.pixelSize: 11

                        MouseArea {
                            anchors.fill: parent
                            onClicked: streamRow.modelData.audio.muted = !streamRow.modelData.audio.muted
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 14
                    color: Config.colors.bg

                    Rectangle {
                        width: parent.width * Math.min(1, streamRow.modelData.audio.volume)
                        height: parent.height
                        color: Config.colors.fg
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => {
                            streamRow.modelData.audio.volume = Math.max(0, Math.min(1, mouse.x / width));
                        }
                    }
                }
            }
        }
    }

    Process {
        id: setDefaultSinkProc
        property int targetId: -1
        function run(id) {
            targetId = id;
            running = true;
        }
        command: ["wpctl", "set-default", String(targetId)]
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// A visual wallpaper picker - shows thumbnails of every image in
// ~/Pictures/wallpapers (change the path below to match your folder) and
// applies the chosen one at runtime via awww, with no restart needed.
//
// Requires: awww (the `awww-daemon` must already be running - start it
// once from your Hyprland autostart). Note: this project was renamed from
// swww to awww in late 2025 - if you installed via a guide referencing
// swww, the actual binaries on a fresh install are awww/awww-daemon.
PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: Qt.rgba(0, 0, 0, 0.55)

    readonly property string wallpaperDir: "/home/kadamx/Pictures/wallpapers"
    property var wallpapers: []

    function refresh() {
        listProc.running = false;
        listProc.running = true;
    }

    onVisibleChanged: if (visible) refresh()

    // Lists image files in the wallpaper directory. find's output (one
    // path per line) is split into the model the GridView consumes.
    Process {
        id: listProc
        command: ["find", window.wallpaperDir, "-maxdepth", "1", "-type", "f",
                   "(", "-iname", "*.png", "-o", "-iname", "*.jpg", "-o",
                   "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                window.wallpapers = text.trim().length > 0
                    ? text.trim().split("\n")
                    : [];
            }
        }
    }

    function applyWallpaper(path) {
        setProc.command = ["awww", "img", path, "--transition-type", "fade", "--transition-duration", "0.5"];
        setProc.running = true;
        window.visible = false;
    }

    Process {
        id: setProc
    }

    Rectangle {
        anchors.centerIn: parent
        width: 720
        height: 480
        radius: 0
        color: Config.colors.surface2
        border.color: Config.colors.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Choose a wallpaper"
                    color: Config.colors.fg
                    font.family: Config.bar.fontFamily
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: 220
                cellHeight: 140
                model: window.wallpapers
                focus: true

                Keys.onEscapePressed: window.visible = false

                delegate: Item {
                    id: cell
                    required property string modelData // file path
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 0
                        color: Config.colors.bgDark
                        border.color: hover.containsMouse ? Config.colors.blue : "transparent"
                        border.width: 2
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + cell.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true

                            // Lower-res thumbnails so swapping through a big
                            // folder doesn't decode full-resolution images
                            // for every tile at once.
                            sourceSize.width: 320
                            sourceSize.height: 200
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: window.applyWallpaper(cell.modelData)
                        }
                    }
                }
            }
        }
    }
}

//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    Bar {}

    Notifications {}

    // The launcher starts hidden - toggle it with the IPC call below,
    // bound to a Hyprland keybind, instead of always being on screen.
    Drun {
        id: drun
        visible: false
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            drun.visible = !drun.visible;
            if (drun.visible)
                drun.forceActiveFocus();
        }
    }

    WallpaperPicker {
        id: wallpaperPicker
        visible: false
    }

    IpcHandler {
        target: "wallpapers"

        function toggle(): void {
            wallpaperPicker.visible = !wallpaperPicker.visible;
        }
    }
}

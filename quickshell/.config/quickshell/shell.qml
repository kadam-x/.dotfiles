//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Modules

ShellRoot {
    Bar {}

    Notifications {}

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

    EmojiPicker {}
}

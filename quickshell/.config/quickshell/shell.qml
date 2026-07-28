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

    NotesPicker {
            id: notesPicker
            visible: false
        }
    IpcHandler {
        target: "notes"
        function toggle(): void {
            notesPicker.visible = !notesPicker.visible;
        }
    }

    EmojiPicker {}
}

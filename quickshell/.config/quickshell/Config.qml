pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property QtObject colors: QtObject {
        readonly property color bg: "#0d0e17"
        readonly property color bgDark: "#1c1c1c"
        readonly property color fg: "#dadada"
        readonly property color muted: "#747474"
        readonly property color cyan: "#7abed3"
        readonly property color purple: "#c481ff"
        readonly property color red: "#dadada"
        readonly property color yellow: "#f38b3f"
        readonly property color blue: "#6aa2ff"

        readonly property color surface2: "#1a2230"
        readonly property color border: "#3a4a66"
    }

    readonly property QtObject bar: QtObject {
        readonly property string fontFamily: "JetBrainsMono Nerd Font"
        readonly property int height: 30
    }

    readonly property QtObject notifications: QtObject {
        readonly property int timeout: 5000
    }
}

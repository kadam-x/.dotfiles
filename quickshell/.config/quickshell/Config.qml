pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property QtObject colors: QtObject {
        readonly property color bg: "#0d0e17"
        readonly property color fg: "#dadada"
        readonly property color muted: "#747474"
        readonly property color accent: "#095c74"
    }

    readonly property QtObject borders: QtObject {
        readonly property int width: 5
    }

    readonly property QtObject bar: QtObject {
        readonly property string fontFamily: "JetBrainsMono Nerd Font"
        readonly property int height: 30
    }

    readonly property QtObject notifications: QtObject {
        readonly property int timeout: 5000
    }
}

import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
    readonly property var vaults: [
        { name: "Notes", path: "/home/kadamx/vaults/notes" },
        { name: "Personal Wiki", path: "/home/kadamx/vaults/personal-wiki" }
    ]
    function openVault(path) {
        launchProc.command = ["xdg-open", "obsidian://open?path=" + encodeURIComponent(path)];
        launchProc.running = true;
        window.visible = false;
    }
    onVisibleChanged: if (visible) {
        list.currentIndex = 0;
        list.forceActiveFocus();
    }
    Process {
        id: launchProc
    }
    MouseArea {
        anchors.fill: parent
        onClicked: window.visible = false
    }
    ListView {
        id: list
        anchors.centerIn: parent
        width: 220
        height: model.length * 44
        model: window.vaults
        focus: true
        keyNavigationEnabled: true
        highlightMoveDuration: 0
        Keys.onEscapePressed: window.visible = false
        Keys.onReturnPressed: window.openVault(model[currentIndex].path)
        Keys.onEnterPressed: window.openVault(model[currentIndex].path)
        delegate: Rectangle {
            id: delegateRoot
            required property var modelData
            required property int index
            width: list.width
            height: 44
            color: (list.currentIndex === index || hover.containsMouse)
                ? Config.colors.accent
                : Config.colors.bg
            border.color: Config.colors.accent
            border.width: Config.borders.width
            Text {
                anchors.centerIn: parent
                text: delegateRoot.modelData.name
                color: (list.currentIndex === delegateRoot.index || hover.containsMouse)
                    ? Config.colors.bg
                    : Config.colors.fg
                font.family: Config.bar.fontFamily
                font.pixelSize: 15
            }
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: window.openVault(delegateRoot.modelData.path)
            }
        }
    }
}

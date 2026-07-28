import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

PanelWindow {
    id: window

    visible: false

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

    IpcHandler {
        target: "drun"

        function toggle() {
            window.visible = !window.visible;
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            selectedIndex = 0;
        }
    }

    readonly property var allApps: {
        const apps = [...DesktopEntries.applications.values];
        apps.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        return apps;
    }

    readonly property var filteredApps: {
        const q = searchField.text.trim().toLowerCase();
        if (q === "")
            return allApps;
        return allApps.filter(entry => {
            const name = (entry.name || "").toLowerCase();
            const comment = (entry.comment || "").toLowerCase();
            return name.includes(q) || comment.includes(q);
        });
    }

    property int selectedIndex: 0

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        window.visible = false;
    }

    Rectangle {
        anchors.centerIn: parent
        width: 510
        height: 420
        radius: 0
        color: Config.colors.bg
        border.color: Config.colors.accent
        border.width: Config.borders.width

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            TextField {
                id: searchField
                Layout.fillWidth: true
                focus: true
                placeholderText: ""
                font.pixelSize: 21
                color: Config.colors.fg
                background: Rectangle {
                    color: Config.colors.bg
                    radius: 0
                    border.color: Config.colors.accent
                    border.width: Config.borders.width
                }

                Keys.onEscapePressed: window.visible = false
                Keys.onReturnPressed: window.launch(window.filteredApps[window.selectedIndex])
                Keys.onDownPressed: window.selectedIndex = Math.min(window.selectedIndex + 1, window.filteredApps.length - 1)
                Keys.onUpPressed: window.selectedIndex = Math.max(window.selectedIndex - 1, 0)
                Keys.onTabPressed: window.selectedIndex = Math.min(window.selectedIndex + 1, window.filteredApps.length - 1)

                onTextChanged: window.selectedIndex = 0
            }

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: window.filteredApps

                highlightFollowsCurrentItem: true
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                currentIndex: window.selectedIndex

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: index === window.selectedIndex

                    width: ListView.view.width
                    height: 34
                    radius: 0
                    color: isSelected ? Config.colors.accent : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        IconImage {
                            source: Quickshell.iconPath(row.modelData.icon, true)
                            implicitSize: 18
                        }

                        Text {
                            text: row.modelData.name
                            color: row.isSelected ? Config.colors.bg : Config.colors.fg
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignLeft
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: window.launch(row.modelData)
                    }
                }
            }
        }
    }
}

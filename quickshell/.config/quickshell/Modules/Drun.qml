import qs
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.bar.height
    color: "#3a3a3a"

    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            selectedIndex = 0;
            searchField.forceActiveFocus();
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        Text {
            text: "run:"
            color: "#f92572"
            font.family: Config.bar.fontFamily
            font.pixelSize: 14
            font.bold: true
        }

        TextInput {
            id: searchField
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            verticalAlignment: TextInput.AlignVCenter
            focus: true
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 14
            selectByMouse: true

            Keys.onEscapePressed: window.visible = false
            Keys.onReturnPressed: window.launch(window.filteredApps[window.selectedIndex])
            Keys.onRightPressed: window.selectedIndex = Math.min(window.selectedIndex + 1, window.filteredApps.length - 1)
            Keys.onLeftPressed: window.selectedIndex = Math.max(window.selectedIndex - 1, 0)
            Keys.onTabPressed: window.selectedIndex = Math.min(window.selectedIndex + 1, window.filteredApps.length - 1)

            onTextChanged: window.selectedIndex = 0
        }

        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 4
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

                width: label.implicitWidth + 36
                height: 26
                radius: 4
                color: isSelected ? "#f92572" : (hover.containsMouse ? "rgba(255,255,255,0.08)" : "transparent")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    IconImage {
                        source: Quickshell.iconPath(row.modelData.icon, true)
                        implicitSize: 16
                    }

                    Text {
                        id: label
                        text: row.modelData.name
                        color: row.isSelected ? "#3a3a3a" : Config.colors.fg
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 13
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

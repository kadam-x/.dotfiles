import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: window

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // Render above everything (Overlay layer) but reserve zero screen
    // space - without this, having 3 anchors makes Hyprland treat this
    // like a bar and push every window down to make room for it.
    exclusionMode: ExclusionMode.Ignore

    // dmenu-style: a single full-width strip docked to the top edge,
    // same as a bar - not a floating centered box.
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Config.bar.height
    color: "#3a3a3a"

    // Reset state every time this window is shown again - it's only ever
    // hidden (visible = false), never destroyed, so without this the
    // TextInput keeps whatever you typed last time around.
    onVisibleChanged: {
        if (visible) {
            searchField.text = "";
            selectedIndex = 0;
            searchField.forceActiveFocus();
        }
    }

    // All installed, visible desktop applications, sorted alphabetically.
    readonly property var allApps: {
        const apps = [...DesktopEntries.applications.values];
        apps.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        return apps;
    }

    // Apps filtered by the current search query.
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

    // Which match is currently highlighted, moved with Left/Right/Tab.
    property int selectedIndex: 0

    function launch(entry) {
        if (!entry)
            return;
        entry.execute();
        window.visible = false; // hide rather than quit - the process stays alive for next time
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

        // Fixed-width input field, like dmenu's prompt box - the match
        // list takes up the remaining space to the right of it.
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

        // The horizontally-scrolling match list - dmenu's signature look.
        ListView {
            id: resultsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: ListView.Horizontal
            spacing: 4
            clip: true
            model: window.filteredApps

            // Keep the selected entry scrolled into view as arrow keys move
            // it - but instantly, not animated. Without highlightMoveDuration
            // set to 0, ListView smoothly eases the viewport on every
            // keypress, which reads as sluggish for something that should
            // feel instant.
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            highlightResizeDuration: 0
            currentIndex: window.selectedIndex

            delegate: Rectangle {
                id: row
                required property var modelData // a DesktopEntry
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

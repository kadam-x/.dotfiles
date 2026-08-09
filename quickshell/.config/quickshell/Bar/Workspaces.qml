import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Row {
    id: root
    property var wsList: []
    property string fontFamily: Config.bar.fontFamily
    property int fontSize: 20
    property bool fontBold: false
    property var switchWorkspace: function(num) {}
    spacing: 6
    Repeater {
        model: root.wsList
        delegate: Rectangle {
            id: wsChip
            required property var modelData
            readonly property bool isFocused: wsChip.modelData.focused
            width: wsRow.implicitWidth + 12
            height: 30
            radius: 0
            color: wsChip.modelData.urgent ? "#ff5454"
                 : (wsChip.isFocused ? "#095c74"
                 : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"))
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.switchWorkspace(wsChip.modelData.num)
            }
            Row {
                id: wsRow
                anchors.centerIn: parent
                spacing: 6
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: wsChip.modelData.name
                    color: wsChip.modelData.urgent ? "#000000" : Config.colors.fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: root.fontBold
                }
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Repeater {
                        model: wsChip.modelData.windows
                        delegate: IconImage {
                            required property var modelData
                            readonly property string appId: modelData.app_id
                                || (modelData.window_properties ? modelData.window_properties.class : "")
                            readonly property var desktopEntry:
                                appId ? DesktopEntries.heuristicLookup(appId) : null
                            source: Quickshell.iconPath(desktopEntry ? desktopEntry.icon : "", true)
                            implicitSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}

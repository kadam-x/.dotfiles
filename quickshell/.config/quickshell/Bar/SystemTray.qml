import qs
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
RowLayout {
    id: root
    property var trayWindow
    spacing: 6
    Layout.rightMargin: 8
    Repeater {
        model: SystemTray.items
        delegate: IconImage {
            id: trayIcon
            required property var modelData
            implicitSize: 18
            source: modelData.icon
            Layout.alignment: Qt.AlignVCenter
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    const pos = trayIcon.mapToItem(null, 0, trayIcon.height);
                    if (mouse.button === Qt.LeftButton) {
                        if (trayIcon.modelData.onlyMenu && trayIcon.modelData.hasMenu)
                            trayIcon.modelData.display(root.trayWindow, pos.x, pos.y);
                        else
                            trayIcon.modelData.activate();
                    } else if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                        trayIcon.modelData.display(root.trayWindow, pos.x, pos.y);
                    }
                }
            }
        }
    }
}

import qs
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    ListModel {
        id: historyModel
    }

    function addToHistory(notification) {
        historyModel.insert(0, {
            notifSummary: notification.summary,
            notifBody: notification.body,
            notifAppName: notification.appName || "",
            notifTime: Qt.formatDateTime(new Date(), "HH:mm")
        });
        while (historyModel.count > 50)
            historyModel.remove(historyModel.count - 1);
    }

    NotificationServer {
        id: server

        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            root.addToHistory(notification);
            notification.tracked = true;
        }
    }

    PanelWindow {
        visible: server.trackedNotifications.values.length > 0

        anchors {
            top: true
            right: true
        }
        margins {
            top: 12
            right: 12
        }

        implicitWidth: 380
        implicitHeight: popupColumn.implicitHeight + 24
        color: "transparent"

        ColumnLayout {
            id: popupColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    implicitHeight: textCol.implicitHeight + 20
                    radius: 0
                    color: Config.colors.bg
                    border.color: Config.colors.accent
                    border.width: Config.borders.width

                    ColumnLayout {
                        id: textCol
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 4

                        Text {
                            text: modelData.summary
                            color: Config.colors.fg
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.body
                            color: Config.colors.muted
                            linkColor: Config.colors.accent
                            font.family: Config.bar.fontFamily
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: modelData.body.length > 0
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: modelData.dismiss()
                    }

                    Timer {
                        interval: Config.notifications.timeout
                        running: true
                        onTriggered: modelData.dismiss()
                    }
                }
            }
        }
    }

    PanelWindow {
        id: historyWindow
        visible: false

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        exclusionMode: ExclusionMode.Ignore

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: historyWindow.visible = false
        }

        Rectangle {
            id: historyPanel
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 40
            anchors.rightMargin: 12
            width: 360
            height: 420
            radius: 0
            color: Config.colors.bg
            border.color: Config.colors.accent
            border.width: Config.borders.width

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            ColumnLayout {
                id: historyColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notifications"
                        color: Config.colors.fg
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Clear"
                        color: Config.colors.accent
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 12

                        MouseArea {
                            anchors.fill: parent
                            onClicked: historyModel.clear()
                        }
                    }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: historyModel

                    Text {
                        anchors.centerIn: parent
                        visible: historyModel.count === 0
                        text: "No notifications yet"
                        color: Config.colors.muted
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 13
                    }

                    delegate: Rectangle {
                        required property string notifSummary
                        required property string notifBody
                        required property string notifAppName
                        required property string notifTime

                        width: ListView.view.width
                        implicitHeight: histTextCol.implicitHeight + 16
                        radius: 0
                        color: Config.colors.bg

                        ColumnLayout {
                            id: histTextCol
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    text: notifSummary
                                    color: Config.colors.fg
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: notifTime
                                    color: Config.colors.muted
                                    font.family: Config.bar.fontFamily
                                    font.pixelSize: 11
                                }
                            }

                            Text {
                                text: notifBody
                                visible: text.length > 0
                                color: Config.colors.muted
                                linkColor: Config.colors.accent
                                font.family: Config.bar.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "notifhistory"

        function toggle(): void {
            historyWindow.visible = !historyWindow.visible;
        }
    }
}

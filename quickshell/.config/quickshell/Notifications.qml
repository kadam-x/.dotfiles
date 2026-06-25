import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    // Notification history - separate from the live popup list below.
    // Entries are appended on arrival and persist after the popup
    // dismisses/expires, until cleared by the user from the history panel.
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
        // cap history length so it doesn't grow forever
        while (historyModel.count > 50)
            historyModel.remove(historyModel.count - 1);
    }

    NotificationServer {
        id: server

        // Full capability advertisement - in particular persistenceSupported,
        // which defaults to false. Clients asking for a persistent/
        // non-auto-dismissing notification (e.g. browser calendar reminders)
        // can decide the system service can't satisfy that and fall back to
        // drawing their own notification UI instead of going through DBus at
        // all if this isn't set.
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

    // ---------------- Live popups (top-right) ----------------
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
                    required property var modelData // a Notification

                    Layout.fillWidth: true
                    implicitHeight: textCol.implicitHeight + 20
                    radius: 0
                    color: Config.colors.surface2
                    border.color: Config.colors.border
                    border.width: 1

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
                            linkColor: Config.colors.cyan
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

    // ---------------- History panel (toggled from the bar) ----------------
    // Covers the whole screen with an invisible backdrop so clicking
    // anywhere outside the panel closes it - the actual visible panel is
    // just anchored top-right within that full-screen window.
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

        // Click-outside-to-close backdrop. Sits behind the panel and
        // covers the full window; the panel itself stops propagation by
        // simply being a sibling Item that the click never reaches through
        // (MouseAreas don't pass clicks to siblings beneath them).
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
            color: Config.colors.surface2
            border.color: Config.colors.border
            border.width: 1

            // Swallow clicks so they don't fall through to the backdrop
            // MouseArea behind this panel.
            MouseArea {
                anchors.fill: parent
                onClicked: {} // consume the click, do nothing
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
                        color: "#4fa8e8"
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
                        color: Config.colors.surface2

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
                                linkColor: Config.colors.cyan
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

import qs
import QtQuick
import Quickshell

PopupWindow {
    id: root

    property var anchorWindow
    property var clockTime
    property bool open: false

    anchor.window: anchorWindow
    anchor.rect.x: anchorWindow.width / 2 - implicitWidth / 2
    anchor.rect.y: anchorWindow.height
    implicitWidth: calColumn.implicitWidth + 16
    implicitHeight: calColumn.implicitHeight + 16
    visible: open
    color: Config.colors.bg

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: Config.colors.accent
        border.width: Config.borders.width
    }

    Column {
        id: calColumn
        anchors.centerIn: parent
        spacing: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 14
            font.bold: true
            text: Qt.formatDateTime(clockTime, "MMMM yyyy")
        }

        Grid {
            columns: 7
            spacing: 6

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: Text {
                    width: 22
                    text: modelData
                    color: Config.colors.fg
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Config.bar.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }

        Grid {
            columns: 7
            spacing: 6

            Repeater {
                model: {
                    const now = clockTime;
                    const year = now.getFullYear();
                    const month = now.getMonth();
                    let firstWeekday = (new Date(year, month, 1)).getDay();
                    firstWeekday = (firstWeekday + 6) % 7;
                    const daysInMonth = new Date(year, month + 1, 0).getDate();
                    let days = [];
                    for (let i = 0; i < firstWeekday; i++) days.push(0);
                    for (let d = 1; d <= daysInMonth; d++) days.push(d);
                    while (days.length % 7 !== 0) days.push(0);
                    return days;
                }

                delegate: Rectangle {
                    id: dayCell
                    required property var modelData
                    readonly property bool isToday: modelData !== 0 && modelData === clockTime.getDate()

                    width: 22
                    height: 22
                    radius: 0
                    color: isToday ? Config.colors.fg : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: dayCell.modelData === 0 ? "" : dayCell.modelData
                        color: dayCell.isToday ? Config.colors.bg : Config.colors.fg
                        font.family: Config.bar.fontFamily
                        font.pixelSize: 11
                        font.bold: dayCell.isToday
                    }
                }
            }
        }

        Text {
            color: Config.colors.fg
            font.family: Config.bar.fontFamily
            font.pixelSize: 12
            text: Qt.formatDateTime(clockTime, "dddd, dd MMMM yyyy")
        }
    }
}

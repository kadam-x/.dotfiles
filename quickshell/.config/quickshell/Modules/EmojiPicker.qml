import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    property bool open: false
    visible: open

    onOpenChanged: {
        if (open) {
            Qt.callLater(() => focusGrab.active = true);
        } else {
            focusGrab.active = false;
        }
    }

    WlrLayershell.namespace: "emoji-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"

    IpcHandler {
        target: "emojipicker"

        function toggle() {
            root.open = !root.open;
            if (root.open) {
                searchField.text = "";
                searchField.forceActiveFocus();
            }
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        onCleared: root.open = false
    }

    readonly property var emojis: [
        { c: "😀", k: "grin smile happy grinning" },
        { c: "😂", k: "laugh joy tears crying laughing lol lmao" },
        { c: "🤣", k: "rofl laugh floor laughing lol" },
        { c: "😍", k: "love heart eyes lovestruck" },
        { c: "😘", k: "kiss blowing kiss" },
        { c: "😎", k: "cool sunglasses awesome" },
        { c: "🤔", k: "think hmm thinking wondering" },
        { c: "😐", k: "neutral meh unimpressed" },
        { c: "😢", k: "cry sad crying tear" },
        { c: "😭", k: "sob cry crying bawling" },
        { c: "😡", k: "angry mad rage furious" },
        { c: "🥳", k: "party celebrate celebration birthday" },
        { c: "😴", k: "sleep tired sleeping zzz" },
        { c: "🤯", k: "mindblown mind blown shock exploding head" },
        { c: "🙄", k: "eyeroll eye roll annoyed" },
        { c: "😏", k: "smirk smug sly" },
        { c: "😒", k: "unamused annoyed" },
        { c: "🙁", k: "frown sad" },
        { c: "😕", k: "confused" },
        { c: "😟", k: "worried" },
        { c: "😢", k: "cry sad" },
        { c: "😭", k: "sob cry" },
        { c: "😤", k: "huff frustrated triumph" },
        { c: "😠", k: "angry mad" },
        { c: "😡", k: "angry rage mad" },
        { c: "🤬", k: "swearing angry" },
        { c: "🤯", k: "mindblown shock" },
        { c: "😳", k: "flushed embarrassed" },
        { c: "🥵", k: "hot sweating" },
        { c: "🥶", k: "cold freezing" },
        { c: "😱", k: "scream scared shock" },
        { c: "😨", k: "fearful scared" },
        { c: "😰", k: "anxious sweat" },
        { c: "😥", k: "sad relief disappointed" },
        { c: "😓", k: "sweat tired" },
        { c: "🤒", k: "sick thermometer" },
        { c: "🤕", k: "hurt injured" },
        { c: "🤢", k: "nauseous sick" },
        { c: "🤮", k: "vomit sick" },
        { c: "🤧", k: "sneeze sick" },
        { c: "🥴", k: "woozy dizzy drunk" },
        { c: "😵", k: "dizzy knockedout" },
        { c: "😵‍💫", k: "dizzy spiral" },
        { c: "🤠", k: "cowboy" },
        { c: "🥳", k: "party celebrate" },
        { c: "🥸", k: "disguise incognito" },
        { c: "😎", k: "cool sunglasses" },
        { c: "🤓", k: "nerd glasses" },
        { c: "🧐", k: "monocle inspect" },
        { c: "😴", k: "sleep tired" },
        { c: "🥱", k: "yawn tired bored" },
        { c: "😪", k: "sleepy tired" },
        { c: "🥺", k: "pleading puppyeyes" },
        { c: "😬", k: "grimace awkward" },
        { c: "🙄", k: "eyeroll" },
        { c: "😷", k: "mask sick" },
        { c: "💀", k: "skull dead lol" },
        { c: "☠️", k: "skullcrossbones danger" },
        { c: "👻", k: "ghost spooky" },
        { c: "👽", k: "alien" },
        { c: "🤖", k: "robot ai bot" },
        { c: "😺", k: "cat happy" },
        { c: "😹", k: "cat laugh" },
        { c: "😻", k: "cat love" },
        { c: "👍", k: "thumbsup thumbs up good yes approve like ok cool" },
        { c: "👎", k: "thumbsdown thumbs down bad no disapprove dislike" },
        { c: "👏", k: "clap applause clapping nice well done" },
        { c: "🙌", k: "raised hands celebrate praise yay" },
        { c: "🙏", k: "pray please thanks thank you praying" },
        { c: "💪", k: "muscle strong flex strength gym workout" },
        { c: "🤝", k: "handshake deal agreement partnership" },
        { c: "🤞", k: "fingers crossed hope luck good luck" },
        { c: "✌️", k: "peace victory sign" },
        { c: "🤟", k: "loveyou love you rock sign" },
        { c: "🤘", k: "rockon rock on metal horns" },
        { c: "👌", k: "ok okay perfect fine good" },
        { c: "🤌", k: "chefskiss chef kiss italian pinch fingers" },
        { c: "👋", k: "wave hello hi bye goodbye" },
        { c: "🤷", k: "shrug idk" },
        { c: "🫡", k: "salute respect" },
        { c: "👀", k: "eyes look" },
        { c: "🧠", k: "brain smart" },
        { c: "🫀", k: "heart organ" },
        { c: "🦴", k: "bone" },
        { c: "🔥", k: "fire lit hot" },
        { c: "💯", k: "hundred perfect" },
        { c: "✨", k: "sparkle shiny" },
        { c: "🎉", k: "party tada confetti" },
        { c: "🎊", k: "confetti party" },
        { c: "⚡", k: "lightning zap fast" },
        { c: "💥", k: "boom explosion" },
        { c: "💫", k: "dizzy stars" },
        { c: "💦", k: "sweat splash water" },
        { c: "💧", k: "droplet water tear" },
        { c: "🌊", k: "wave ocean" },
        { c: "⭐", k: "star favorite" },
        { c: "🌟", k: "star glow" },
        { c: "❤️", k: "heart love red" },
        { c: "🧡", k: "heart orange" },
        { c: "💛", k: "heart yellow" },
        { c: "💚", k: "heart green" },
        { c: "💙", k: "heart blue" },
        { c: "💜", k: "heart purple" },
        { c: "🖤", k: "heart black" },
        { c: "🤍", k: "heart white" },
        { c: "🤎", k: "heart brown" },
        { c: "💔", k: "brokenheart sad" },
        { c: "❤️‍🔥", k: "heart fire passion" },
        { c: "💕", k: "hearts love" },
        { c: "💖", k: "sparkling heart" },
        { c: "💘", k: "heart arrow cupid" },
        { c: "✅", k: "check done yes correct" },
        { c: "❌", k: "cross no wrong error" },
        { c: "⚠️", k: "warning caution" },
        { c: "❓", k: "question mark" },
        { c: "❗", k: "exclamation mark" },
        { c: "♻️", k: "recycle" },
        { c: "🚀", k: "rocket launch fast" },
        { c: "💻", k: "laptop code computer" },
        { c: "🖥️", k: "desktop computer" },
        { c: "⌨️", k: "keyboard" },
        { c: "🖱️", k: "mouse computer" },
        { c: "🐧", k: "linux penguin" },
        { c: "🐛", k: "bug" },
        { c: "🪲", k: "beetle bug" },
        { c: "🧩", k: "puzzle piece plugin" },
        { c: "🔧", k: "wrench tool fix" },
        { c: "🔩", k: "nutbolt tool" },
        { c: "⚙️", k: "gear settings config" },
        { c: "🧪", k: "test science experiment" },
        { c: "📈", k: "chart up gains" },
        { c: "📉", k: "chart down loss" },
        { c: "📊", k: "barchart stats data" },
        { c: "💰", k: "money cash bag" },
        { c: "💵", k: "dollar money cash" },
        { c: "💸", k: "money flying spend" },
        { c: "🏦", k: "bank" },
        { c: "🐂", k: "bull market" },
        { c: "🐻", k: "bear market" },
        { c: "☕", k: "coffee" },
        { c: "🍕", k: "pizza food" },
        { c: "🍔", k: "burger food" },
        { c: "🍜", k: "noodles ramen food" },
        { c: "🍺", k: "beer drink" },
        { c: "🥤", k: "drink cup" },
        { c: "🌙", k: "moon night" },
        { c: "☀️", k: "sun day" },
        { c: "☁️", k: "cloud" },
        { c: "🌧️", k: "rain" },
        { c: "❄️", k: "snow snowflake" }
    ]

    property var filtered: {
        const words = searchField.text.trim().toLowerCase().split(/\s+/).filter(w => w.length > 0);
        if (words.length === 0)
            return emojis;
        return emojis.filter(e => words.every(w => e.k.includes(w)));
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 510
        height: 630
        color: Config.colors.bg

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Config.colors.accent
            border.width: Config.borders.width
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: ""
                font.pixelSize: 21
                color: Config.colors.fg
                background: Rectangle {
                    color: Config.colors.bg
                    radius: 0
                    border.color: Config.colors.accent
                    border.width: Config.borders.width
                }
                Keys.onEscapePressed: root.open = false
                onAccepted: {
                    if (root.filtered.length > 0) {
                        copyProc.emoji = root.filtered[0].c;
                        copyProc.running = true;
                        root.open = false;
                    }
                }
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 60
                cellHeight: 60
                clip: true
                model: root.filtered

                delegate: Rectangle {
                    required property var modelData
                    width: 54
                    height: 54
                    radius: 0
                    color: hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData.c
                        font.pixelSize: 28
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            copyProc.emoji = parent.modelData.c;
                            copyProc.running = true;
                            root.open = false;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: copyProc
        property string emoji: ""
        command: ["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", emoji]
    }
}

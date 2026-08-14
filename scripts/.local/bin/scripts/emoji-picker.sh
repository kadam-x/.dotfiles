#!/bin/sh
# Emoji picker via fuzzel --dmenu. Copies the chosen emoji to the clipboard.

emojis="😀 grinning face
😃 grinning face with big eyes
😄 grinning face with smiling eyes
😁 beaming face
😆 grinning squinting face
😅 grinning face with sweat
🤣 rolling on the floor laughing
😂 face with tears of joy
🙂 slightly smiling face
🙃 upside-down face
😉 winking face
😊 smiling face with smiling eyes
😍 heart eyes
😘 face blowing a kiss
😎 smiling face with sunglasses
🤔 thinking face
😐 neutral face
😑 expressionless face
😴 sleeping face
😭 loudly crying face
😡 pouting face
🤯 exploding head
🥳 partying face
😱 face screaming in fear
🤢 nauseated face
🤮 vomiting face
🥺 pleading face
😤 face with steam from nose
💀 skull
👻 ghost
🔥 fire
✨ sparkles
🎉 party popper
💯 hundred points
👍 thumbs up
👎 thumbs down
👌 ok hand
🤝 handshake
🙏 folded hands
👀 eyes
💪 flexed biceps
❤️ red heart
🖤 black heart
💔 broken heart
🚀 rocket
⭐ star
☕ coffee
🍕 pizza
🐛 bug
✅ check mark
❌ cross mark
⚡ lightning bolt"

chosen=$(printf '%s\n' "$emojis" | bemenu -i -p "emoji:" | cut -d' ' -f1)

if [ -n "$chosen" ]; then
    printf '%s' "$chosen" | wl-copy
    notify-send "Copied" "$chosen"
fi

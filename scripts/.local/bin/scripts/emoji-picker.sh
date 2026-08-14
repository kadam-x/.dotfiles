#!/usr/bin/env bash

EMOJI_FILE="$HOME/.local/bin/scripts/emoji_list.txt"

chosen=$(bemenu -p 'emoji:' < "$EMOJI_FILE" | awk '{print $1}')

if [ -n "$chosen" ]; then
    printf "%s" "$chosen" | wl-copy
fi

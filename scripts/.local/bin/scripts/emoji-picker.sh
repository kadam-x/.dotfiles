#!/usr/bin/env bash

EMOJI_FILE="$HOME/.local/bin/scripts/emoji_list.txt"

chosen=$(eval "bemenu -p 'emoji:' $BEMENU_OPTS" < "$EMOJI_FILE" | awk '{print $1}')

if [ -n "$chosen" ]; then
    printf "%s" "$chosen" | wl-copy
fi

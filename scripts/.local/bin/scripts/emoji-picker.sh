#!/usr/bin/env bash

EMOJI_FILE="$HOME/.local/bin/scripts/emoji_list.txt"

chosen=$(cut -d';' -f1 "$EMOJI_FILE" | bemenu $bemenu_opts | awk '{print $1}')

if [ -n "$chosen" ]; then
    printf "%s" "$chosen" | wl-copy
fi

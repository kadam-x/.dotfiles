#!/usr/bin/env bash
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

awww-daemon &>/dev/null &
selection=$(ls "$WALLPAPER_DIR" | tofi --prompt-text "wallpaper > ")

[ -z "$selection" ] && exit 0

awww img "$WALLPAPER_DIR/$selection" --transition-type simple

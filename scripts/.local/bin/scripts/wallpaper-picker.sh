#!/usr/bin/env bash
wp_dir="$HOME/Pictures/wallpapers"

selected=$(find "$wp_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -printf "%f\n" | sort | bemenu --fn "monospace 17" -p "wallpaper:")

[ -z "$selected" ] && exit 0

awww img "$wp_dir/$selected"

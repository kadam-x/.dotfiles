#!/bin/sh
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

geom=$(slurp) || exit 0   # cancelled: do nothing

file="$dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
grim -g "$geom" "$file" || { rm -f "$file"; exit 1; }

wl-copy -t image/png < "$file"
notify-send -i "$file" "Screenshot saved" "$file"

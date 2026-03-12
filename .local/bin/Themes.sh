#!/bin/bash

export PATH=$PATH:/usr/bin:/bin:/home/skeken/.local/bin
export XDG_RUNTIME_DIR=/run/user/1000

DIR="/home/skeken/.config/hypr/Wallpaper"
MONITOR="eDP-1"

# 1. Rofi Interface (Horizontal Grid Layout)
CHOICE=$(
    for file in "$DIR"/*.{jpg,jpeg,png,webp}; do
        [ -f "$file" ] || continue
        name=$(basename "$file")
        echo -en "${name}\0icon\x1f${file}\n"
    done | rofi -dmenu -i -p "Select Theme" -show-icons \
        -theme-str 'window { width: 1000px; }' \
        -theme-str 'listview { columns: 4; lines: 1; spacing: 20px; }' \
        -theme-str 'element { orientation: vertical; padding: 15px; children: [ element-icon, element-text ]; }' \
        -theme-str 'element-icon { size: 200px; horizontal-align: 0.5; }' \
        -theme-str 'element-text { horizontal-align: 0.5; font: "Sans 12"; }'
)

# Exit if Esc is pressed
[ -z "$CHOICE" ] && exit 1

# 2. Clean Path (Keep this safe!)
CLEAN_CHOICE=$(echo "$CHOICE" | sed 's/[[:cntrl:]]//g')
FULL_PATH="$DIR/$CLEAN_CHOICE"

# 3. Apply Wallpaper
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$FULL_PATH"
hyprctl hyprpaper wallpaper "$MONITOR,$FULL_PATH"

# 4. Generate Colors
wal -i "$FULL_PATH" -n -q -e --backend colorthief

# 5. Reload Apps
sleep 0.3
pkill -USR1 kitty
pywalfox update 2>/dev/null
pkill waybar
nohup waybar > /dev/null 2>&1 & disown

notify-send "Theme Applied" "$CLEAN_CHOICE"

#!/bin/bash

export PATH=$PATH:/usr/bin:/bin:/home/skeken/.local/bin
export XDG_RUNTIME_DIR=/run/user/1000

DIR="/home/skeken/.config/hypr/Wallpaper"

# 1. Rofi Interface (Now looking for .gif too!)
CHOICE=$(
    for file in "$DIR"/*.{jpg,jpeg,png,webp,gif}; do
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

[ -z "$CHOICE" ] && exit 1

# 2. Clean Path
CLEAN_CHOICE=$(echo "$CHOICE" | sed 's/[[:cntrl:]]//g')
FULL_PATH="$DIR/$CLEAN_CHOICE"

# 3. Ensure swww daemon is running quietly
swww query >/dev/null 2>&1 || swww-daemon >/dev/null 2>&1 &
sleep 0.1

# 4. Apply Wallpaper with a cool expanding circle transition (silenced)
swww img "$FULL_PATH" --transition-type center --transition-duration 1 --transition-fps 60 >/dev/null 2>&1

# 5. Generate Colors
wal -i "$FULL_PATH" -n -q -e --backend colorthief

# 6. Reload Apps
sleep 0.3
pkill -USR1 kitty
pywalfox update 2>/dev/null
pkill waybar
nohup waybar > /dev/null 2>&1 & disown

notify-send "Theme Applied" "$CLEAN_CHOICE"

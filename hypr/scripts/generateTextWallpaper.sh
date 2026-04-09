#!/bin/bash

# Temp file for editing text
TMP_FILE="/tmp/wallpaper_text.txt"

# Output wallpaper path
OUTPUT="$HOME/Pictures/wallpaper/text.png"

# Open nvim to write text
nvim "$TMP_FILE"

# If file is empty, exit
if [ ! -s "$TMP_FILE" ]; then
    echo "No text entered. Exiting."
    exit 1
fi

# Generate wallpaper using ImageMagick
magick -size 1920x1080 xc:black \
  -gravity northwest \
  -font "DejaVu-Sans" \
  -pointsize 80 \
  -fill white \
  -interline-spacing 20 \
  -annotate +100+150 @"$TMP_FILE" \
  "$OUTPUT"

# Reload Hyprpaper
awww img "$HOME/Pictures/wallpaper/text.png"

echo "Wallpaper updated successfully!"

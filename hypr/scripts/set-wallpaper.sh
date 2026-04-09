#!/bin/bash

wallpaper="$1"

if [ -z "$wallpaper" ]; then
    echo "No wallpaper provided"
    exit 1
fi

# Set wallpaper (ONLY ONCE)
hyprctl hyprpaper preload "$wallpaper"
hyprctl hyprpaper wallpaper ",$wallpaper"

echo "Wallpaper set: $wallpaper"

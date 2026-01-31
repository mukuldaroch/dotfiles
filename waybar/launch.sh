#!/bin/bash

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------
killall waybar
pkill waybar
sleep 0.5

# -----------------------------------------------------
# Default theme: /THEMEFOLDER
# -----------------------------------------------------
themestyle="/waybar-white"

# -----------------------------------------------------
# Get current theme information from ~/.config/waybar/scripts/waybar-theme.sh
# -----------------------------------------------------
if [ -f ~/.config/waybar/settings/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/waybar/settings/waybar-theme.sh)
else
    touch ~/.config/waybar/settings/waybar-theme.sh
    echo "$themestyle" >~/.config/waybar/settings/waybar-theme.sh
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle="/waybar-black;/waybar-black"
fi

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------
config_file="config"
style_file="style.css"

# Standard files can be overwritten with an existing config-custom or style-custom.css
if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi

# Check if waybar-disabled file exists
if [ ! -f $HOME/.config/waybar/settings/waybar-disabled ]; then
    waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file &
else
    echo ":: Waybar disabled"
fi

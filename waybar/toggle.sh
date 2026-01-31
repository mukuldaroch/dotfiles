#!/bin/bash

if [ -f $HOME/.config/waybar/settings/waybar-disabled ]; then
    rm $HOME/.config/waybar/settings/waybar-disabled
else
    touch $HOME/.config/waybar/settings/waybar-disabled
fi
$HOME/.config/waybar/launch.sh &

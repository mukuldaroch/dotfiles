#!/bin/bash

prompt='Screenshot'
mesg="DIR: ~/Screenshots"

# Screenshot Filename
NAME="screenshot_$(date +%d%m%Y_%H%M%S).jpg"

# Screenshot Folder
screenshot_folder="$HOME/Pictures/screenshots/"

# Take screenshot immediately
takescreenshot() {
	#   sleep 1
	grimblast save active "$HOME/$NAME"

	# Move to the screenshot folder if defined
	if [ -f "$HOME/$NAME" ] && [ -d "$screenshot_folder" ]; then
		mv "$HOME/$NAME" "$screenshot_folder/"
	fi

	notify-send "Screenshot Taken" "Saved to $screenshot_folder"
}

# Run screenshot function
takescreenshot

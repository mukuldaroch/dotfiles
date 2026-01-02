#
# Based on https://github.com/hyprwm/contrib/blob/main/grimblast/screenshot.sh 
# ----------------------------------------------------- 

# Screenshots will be stored in $HOME by default.
# The screenshot will be moved into the screenshot directory

# Add this to ~/.config/user-dirs.dirs to save screenshots in a custom folder: 
# XDG_SCREENSHOTS_DIR="$HOME/Screenshots"

#!/bin/bash

prompt='Screenshot'
mesg="DIR: ~/Screenshots"

# Screenshot Filename
source ~/.config/ml4w/settings/screenshot-filename.sh

# Screenshot Folder
source ~/.config/ml4w/settings/screenshot-folder.sh

# Screenshot Editor
export GRIMBLAST_EDITOR="$(cat ~/.config/ml4w/settings/screenshot-editor.sh)"

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

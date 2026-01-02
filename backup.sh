#!/bin/bash

backup_directory() {
    local SOURCE_DIR="$1"
    local DEST_DIR="$2"

    mkdir -p "$DEST_DIR"

    rsync -a \
        --delete \
        --no-motd \
        --out-format='%n' \
        "$SOURCE_DIR" "$DEST_DIR"

    echo "Backup synced for $SOURCE_DIR"
}

backup_directory "$HOME/.config/waybar/themes/custom/" "$HOME/backup/waybar/custom-white/"
backup_directory "$HOME/.config/waybar/themes/custom_black/" "$HOME/backup/waybar/custom_black/"
backup_directory "$HOME/.config/hypr/" "$HOME/backup/hypr/"
backup_directory "$HOME/.config/kitty/" "$HOME/backup/kitty/"
backup_directory "$HOME/.config/nvim/" "$HOME/backup/nvim/"
backup_directory "$HOME/.config/yazi/" "$HOME/backup/yazi/"
backup_directory "$HOME/.config/bashrc/" "$HOME/backup/bashrc/"

backup_directory "$HOME/.config/lazygit/" "$HOME/backup/lazygit/"
backup_directory "$HOME/.config/ohmyposh/" "$HOME/backup/ohmyposh/"
backup_directory "$HOME/.config/rofi/" "$HOME/backup/rofi/"
backup_directory "$HOME/.config/tmux/" "$HOME/backup/tmux/"
backup_directory "$HOME/.config/wlogout/" "$HOME/backup/wlogout/"
backup_directory "$HOME/.config/dunst/" "$HOME/backup/dunst/"
backup_directory "$HOME/.config/ml4w/" "$HOME/backup/ml4w/"

echo ""
echo "All backups fully synchronized."

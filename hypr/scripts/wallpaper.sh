#!/bin/bash
#  _      __     ____
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/
#                /_/       /_/

# -----------------------------------------------------
# Set defaults
# -----------------------------------------------------

force_generate=0
generatedversions="$HOME/.config/daroch/cache/wallpaper-generated"
# waypaperrunning=$HOME/.config/daroch/cache/waypaper-running
cachefile="$HOME/.config/daroch/cache/current_wallpaper"
blurredwallpaper="$HOME/.config/daroch/cache/wallpaper-generated/blurred_wallpaper.png"
rasifile="$HOME/.config/daroch/cache/current_wallpaper.rasi"
# blurfile="$HOME/.config/daroch/settings/blur.sh"
defaultwallpaper="$HOME/Pictures/wallpaper/clay-banks.jpg"
# wallpapereffect="$HOME/.config/daroch/settings/wallpaper-effect.sh"
blur="2x2"

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ]; then
	if [ -z "$1" ]; then
		exit 0
	fi
else
	wallpaper=$1
fi
used_wallpaper=$wallpaper
echo ":: Setting wallpaper with source image $wallpaper"

# -----------------------------------------------------
# Copy path of current wallpaper to cache file
# -----------------------------------------------------

if [ ! -f $cachefile ]; then
	touch $cachefile
fi
echo "$wallpaper" >$cachefile
echo ":: Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaperfilename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Execute pywal
# -----------------------------------------------------

# echo ":: Execute pywal with $used_wallpaper"
# wal -q -i "$used_wallpaper"
# source "$HOME/.config/kitty/themes/colors.sh"

# -----------------------------------------------------
# Update Pywalfox
# -----------------------------------------------------

# if type pywalfox >/dev/null 2>&1; then
#     pywalfox update
# fi

# -----------------------------------------------------
# Update SwayNC
# -----------------------------------------------------
# sleep 0.1
# swaync-client -rs

# -----------------------------------------------------
# Skip blur generation for GIF wallpapers
# -----------------------------------------------------

wallpaper_ext="${used_wallpaper##*.}"
wallpaper_ext="${wallpaper_ext,,}"

if [ "$wallpaper_ext" = "gif" ]; then
	echo ":: GIF wallpaper detected — skipping blur generation"
	echo "* { current-image: url(\"$used_wallpaper\", height); }" >"$rasifile"
	exit 0
fi

# -----------------------------------------------------
# Cleanup old blurred wallpaper
# -----------------------------------------------------

echo ":: Cleaning old blurred wallpaper"
rm -f $generatedversions/blurred_wallpaper.png

# -----------------------------------------------------
# Create blurred wallpaper (FAST + SAFE)
# -----------------------------------------------------

echo ":: Generating blurred wallpaper"

pkill magick

sleep 0.5

# magick "$used_wallpaper" -blur "$blur" "$blurredwallpaper"
magick "$used_wallpaper" -filter Gaussian -resize 50% -define filter:sigma=2.5 -resize 200% "$blurredwallpaper"

echo ":: Blurred with sigma 1.2"

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
	touch $rasifile
fi

echo "* { current-image: url(\"$blurredwallpaper\", height); }" >"$rasifile"

echo "Blured wallpaper updated"

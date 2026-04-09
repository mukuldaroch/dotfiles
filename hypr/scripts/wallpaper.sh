#!/bin/bash
#  _      __     ____
# | | /| / /__ _/ / /__  ___ ____  ___ ____
# | |/ |/ / _ `/ / / _ \/ _ `/ _ \/ -_) __/
# |__/|__/\_,_/_/_/ .__/\_,_/ .__/\__/_/
#                /_/       /_/
# -----------------------------------------------------
# Check to use wallpaper cache
# -----------------------------------------------------

# if [ -f ~/.config/daroch/settings/wallpaper_cache ]; then
#     use_cache=1
#     echo ":: Using Wallpaper Cache"
# else
#     use_cache=0
#     echo ":: Wallpaper Cache disabled"
# fi

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

# # Ensures that the script only run once if wallpaper effect enabled
# if [ -f $waypaperrunning ]; then
#     rm $waypaperrunning
#     exit
# fi

# Create folder with generated versions of wallpaper if not exists
if [ ! -d $generatedversions ]; then
    mkdir $generatedversions
fi

# -----------------------------------------------------
# Get selected wallpaper
# -----------------------------------------------------

if [ -z $1 ]; then
    if [ -z "$1" ]; then
        exit 0
    fi
    # if [ -f $cachefile ]; then
    #     wallpaper=$(cat $cachefile)
    # else
    #     wallpaper=$defaultwallpaper
    # fi
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
echo "$wallpaper" > $cachefile
echo ":: Path of current wallpaper copied to $cachefile"

# -----------------------------------------------------
# Get wallpaper filename
# -----------------------------------------------------
wallpaperfilename=$(basename $wallpaper)
echo ":: Wallpaper Filename: $wallpaperfilename"

# -----------------------------------------------------
# Wallpaper Effects
# -----------------------------------------------------

# if [ -f $wallpapereffect ]; then
#     effect=$(cat $wallpapereffect)
#     if [ ! "$effect" == "off" ]; then
#         used_wallpaper=$generatedversions/$effect-$wallpaperfilename
#         if [ -f $generatedversions/$effect-$wallpaperfilename ] && [ "$force_generate" == "0" ] && [ "$use_cache" == "1" ]; then
#             echo ":: Use cached wallpaper $effect-$wallpaperfilename"
#         else
#             echo ":: Generate new cached wallpaper $effect-$wallpaperfilename with effect $effect"
#             notify-send --replace-id=1 "Using wallpaper effect $effect..." "with image $wallpaperfilename" -h int:value:33
#             source $HOME/.config/hypr/effects/wallpaper/$effect
#         fi
#         echo ":: Loading wallpaper $generatedversions/$effect-$wallpaperfilename with effect $effect"
#         echo ":: Setting wallpaper with $used_wallpaper"
#         touch $waypaperrunning
#         waypaper --wallpaper $used_wallpaper
#     else
#         echo ":: Wallpaper effect is set to off"
#     fi
# else
#     effect="off"
# fi

# -----------------------------------------------------
# Execute pywal
# -----------------------------------------------------

# echo ":: Execute pywal with $used_wallpaper"
# wal -q -i "$used_wallpaper"
# source "$HOME/.config/kitty/themes/colors.sh"

# -----------------------------------------------------
# Walcord
# -----------------------------------------------------

# if type walcord >/dev/null 2>&1; then
#     walcord
# fi

# -----------------------------------------------------
# Reload Waybar
# -----------------------------------------------------

# killall -SIGUSR2 waybar

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
    echo "* { current-image: url(\"$used_wallpaper\", height); }" > "$rasifile"
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

# magick "$used_wallpaper" -blur "$blur" "$blurredwallpaper"
magick "$used_wallpaper" -filter Gaussian -resize 50% -define filter:sigma=2.5 -resize 200% "$blurredwallpaper"

echo ":: Blurred with sigma 1.2"

# -----------------------------------------------------
# Create rasi file
# -----------------------------------------------------

if [ ! -f $rasifile ]; then
    touch $rasifile
fi

echo "* { current-image: url(\"$blurredwallpaper\", height); }" > "$rasifile"

echo "Blured wallpaper updated"

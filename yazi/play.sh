#!/bin/bash

file="$1"

# Get mime type
mime=$(file --mime-type -b "$file")

# Extract extension (lowercase)
ext="${file##*.}"
ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

case "$mime" in
video/*)
	pkill -x mpv
	mpv --force-window "$file" &
	;;
audio/*)
	pkill -x mpv
	mpv --no-video --force-window=no --input-ipc-server="/tmp/mpvsocket" "$file" &
	notify-send "🎵 Playing" "$(basename "$file")"
	;;
image/*)
	pkill -x viewnior
	viewnior "$file" &
	;;
*)
	case "$ext" in
	mp4 | mkv | webm | avi | mov)
		pkill -x mpv
		mpv --force-window "$file" &
		;;
	mp3 | wav | flac | ogg)
		pkill -x mpv
		mpv --no-video --force-window=no "$file" &
		notify-send "🎵 Playing" "$(basename "$file")"
		;;
	jpg | jpeg | png | gif | bmp | webp)
		pkill -x viewnior
		viewnior "$file" &
		;;
	*)
		echo "Unknown file type: $mime ($ext)"
		;;
	esac
	;;
esac

#!/bin/bash

file="$1"
mime=$(file --mime-type -b "$file")


case "$mime" in
    video/*)
        pkill -x mpv
        mpv --force-window "$file" &
	# ffplay "$file"
        # notify-send "Playing" "$(basename "$file")"
        ;;
    audio/*)
        # Kill any existing mpv process
        pkill -x mpv
        mpv --no-video --force-window=no --input-ipc-server="/tmp/mpvsocket" "$file" &
        notify-send "🎵 Playing" "$(basename "$file")"
        ;;
    *)
        echo "Unknown file type: $mime"
        ;;
esac

#!/bin/bash

file="$1"
mime=$(file --mime-type -b "$file")

# Kill any existing mpv process
pkill -x mpv

case "$mime" in
    video/*)
        ffplay -autoexit "$file" >/dev/null 2>&1 &
        ;;
    audio/*)
        mpv --no-video --force-window=no --input-ipc-server="/tmp/mpvsocket" "$file" &
        notify-send "🎵 Now Playing" "$(basename "$file")"
        ;;
    *)
        echo "Unknown file type: $mime"
        ;;
esac

#!/bin/bash

sudo tcpdump -l -i any 2>/dev/null | while read line
do
    if echo "$line" | grep -qi "instagram"; then
        notify-send "⚠️ Focus bro" "Instagram network request detected"
    sleep 5
    fi
done

#!/bin/bash
ACTIVE_WIN=$(xdotool getactivewindow 2>/dev/null)
[ -z "$ACTIVE_WIN" ] && exit 0

WIN_CLASS=$(xprop -id $ACTIVE_WIN 2>/dev/null | grep "WM_CLASS")

if [[ "$WIN_CLASS" == *"nemo-desktop"* ]] || [[ "$WIN_CLASS" == *"Cinnamon"* ]] || [[ "$WIN_CLASS" == *"cinnamon"* ]]; then
    exit 0
else
    sh -c "sleep 0.1 && xdotool windowminimize $ACTIVE_WIN"
fi

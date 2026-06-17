#!/bin/bash
sleep 5
journalctl -u earlyoom -f --output=cat | grep --line-buffered -E "sending SIG(TERM|KILL) to process" | while read -r line; do
    PROCESS_NAME=$(echo "$line" | grep -oP '(?<=")[^"]+(?=")')
    zenity --error --title="Запобігання зависанню" --text="Програму <b>$PROCESS_NAME</b> було примусово закрито системою через критичну нестачу оперативної пам'яті." --width=400 &
done
EOF
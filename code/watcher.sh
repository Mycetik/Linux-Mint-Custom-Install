#!/bin/bash
# Чекаємо 5 секунд після старту системи, щоб графіка встигла завантажитись
sleep 5

# Читаємо лог earlyoom у реальному часі
journalctl -u earlyoom -f --output=cat | grep --line-buffered -E "sending SIGTERM to process|sending SIGKILL to process" | while read -r line; do
    # Витягуємо назву програми (текст між лапками)
    PROCESS_NAME=$(echo "$line" | grep -oP '(?<=")[^"]+(?=")')
    
    # Виводимо графічне вікно
    zenity --error --title="Запобігання зависанню" --text="Програму <b>$PROCESS_NAME</b> було примусово закрито системою через критичну нестачу оперативної пам'яті." --width=400 &
done

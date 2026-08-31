#!/bin/bash
# /usr/local/bin/target-setup.sh

LOG="/var/log/nvidia-post-install.log"
echo "$(date)" > "$LOG"

echo "Налаштування..." >> "$LOG"
mkdir -p /etc/lightdm/lightdm.conf.d

NEW_USER=$(awk -F: '$3==1000 {print $1}' /etc/passwd)

cat <<EOF > /etc/lightdm/lightdm.conf.d/99-phase2-autologin.conf
[Seat:*]
autologin-user=$NEW_USER
autologin-user-timeout=0
EOF

echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-phase2-nopasswd
chmod 0440 /etc/sudoers.d/99-phase2-nopasswd

echo "Перевірка наявності Інтернету..." >> "$LOG"
if curl -Is --connect-timeout 5 google.com > /dev/null 2>&1; then
    
    GPU_INFO=$(lspci | grep -iE 'vga|3d' | grep -i nvidia)
    
    if [ -n "$GPU_INFO" ]; then
        echo "Знайдено NVIDIA GPU: $GPU_INFO" >> "$LOG"

        add-apt-repository -y ppa:graphics-drivers/ppa >> "$LOG" 2>&1
        apt-get update -y >> "$LOG" 2>&1
   
        if echo "$GPU_INFO" | grep -iqE 'RTX|16[0-9]{2}|20[0-9]{2}|30[0-9]{2}|40[0-9]{2}|50[0-9]{2}|10[0-9]{2}'; then
            echo "Встановлюємо nvidia-driver-580..." >> "$LOG"
            DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-driver-580 >> "$LOG" 2>&1
            
        elif echo "$GPU_INFO" | grep -iqE '9[0-9]{2}|TITAN X'; then
            echo "Встановлюємо nvidia-driver-535..." >> "$LOG"
            DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-driver-535 >> "$LOG" 2>&1
            
        else
            echo "Залишаємо відкритий драйвер Nouveau" >> "$LOG"
        fi
    else
        echo "Відеокарту NVIDIA не знайдено. Пропуск" >> "$LOG"
    fi
else
    echo "Немає Інтернету! Пропуск встановлення драйверів" >> "$LOG"
fi

echo "Завершено" >> "$LOG"
exit 0

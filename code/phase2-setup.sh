#!/bin/bash
# /etc/skel/.local/bin/phase2-setup.sh

LOG_FILE="$HOME/phase2-setup.log"
echo "Друга фаза установки Linux Mint: $(date)" > "$LOG_FILE"

if [ "$USER" = "mint" ]; then
    echo "Запущено на Live-флешці. Вихід" >> "$LOG_FILE"
    exit 0
fi

rm -f "$HOME/.config/autostart/ubiquity.desktop" >> "$LOG_FILE" 2>&1

echo "Створюємо чорну кімнату" >> "$LOG_FILE"
gsettings set org.nemo.desktop show-desktop-icons false >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop volumes-visible false >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop computer-icon-visible false >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop trash-icon-visible false >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop home-icon-visible false >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop network-icon-visible false >> "$LOG_FILE" 2>&1

gsettings set org.cinnamon.desktop.background picture-options 'none' >> "$LOG_FILE" 2>&1
gsettings set org.cinnamon.desktop.background primary-color '#000000' >> "$LOG_FILE" 2>&1
gsettings set org.cinnamon panels-autohide "['1:true', '2:true']" >> "$LOG_FILE" 2>&1

(
    echo "5" ; echo "# Перевірка мережі"
    echo "Перевірка мережі через curl" >> "$LOG_FILE"
    ONLINE=false
    for i in {1..15}; do
        if curl -Is --connect-timeout 2 google.com >/dev/null 2>&1; then
            ONLINE=true
            echo "Мережа знайдена (спроба $i)" >> "$LOG_FILE"
            break
        fi
        echo "Очікування мережі (спроба $i)..." >> "$LOG_FILE"
        sleep 2
    done

    if [ "$ONLINE" = true ]; then
        echo "10" ; echo "# Оновлення репозиторіїв"
        echo "Додавання репозиторію Flathub..." >> "$LOG_FILE"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
        
        echo "18" ; echo "# Встановлення MissionCenter"
        echo "Встановлення MissionCenter..." >> "$LOG_FILE"
        flatpak install -y flathub io.missioncenter.MissionCenter >> "$LOG_FILE" 2>&1
        
        echo "26" ; echo "# Встановлення Resources"
        echo "Встановлення Resources..." >> "$LOG_FILE"
        flatpak install -y flathub net.nokyan.Resources >> "$LOG_FILE" 2>&1
        
        echo "40" ; echo "# Встановлення Bottles"
        echo "Встановлення Bottles..." >> "$LOG_FILE"
        flatpak install -y flathub com.usebottles.bottles >> "$LOG_FILE" 2>&1
        
        echo "50" ; echo "# Встановлення Emote"
        echo "Встановлення Emote..." >> "$LOG_FILE"
        flatpak install -y flathub com.tomjwatson.Emote >> "$LOG_FILE" 2>&1
        
        echo "58" ; echo "# Встановлення KolourPaint"
        echo "Встановлення KolourPaint..." >> "$LOG_FILE"
        flatpak install -y flathub org.kde.kolourpaint >> "$LOG_FILE" 2>&1
        
        echo "66" ; echo "# Встановлення Flatseal"
        echo "Встановлення Flatseal..." >> "$LOG_FILE"
        flatpak install -y flathub com.github.tchx84.Flatseal >> "$LOG_FILE" 2>&1
        
        echo "74" ; echo "# Встановлення EasyEffects"
        echo "Встановлення EasyEffects..." >> "$LOG_FILE"
        flatpak install -y flathub com.github.wwmm.easyeffects >> "$LOG_FILE" 2>&1
    else
        echo "75" ; echo "# Мережа відсутня. Пропуск встановлення додатків"
        echo "ПРОПУСК: Мережа відсутня" >> "$LOG_FILE"
        sleep 3
    fi 

    echo "78" ; echo "# Налаштування зміни мови"
    echo "Вибір сполучення клавіш для перемикання мови..." >> "$LOG_FILE"

    gsettings set org.cinnamon.desktop.keybindings.wm switch-input-source "['unbound']" >> "$LOG_FILE" 2>&1

    LANG_SHORTCUT=$(zenity --list \
        --title="Налаштування розкладки" \
        --text="Оберіть сполучення клавіш для перемикання мови:" \
        --radiolist \
        --column="Вибір" --column="Сполучення" \
        TRUE "Alt + Shift" \
        FALSE "Ctrl + Shift" \
        FALSE "Win + Пробіл" \
        --width=350 --height=220)

    case "$LANG_SHORTCUT" in
        "Alt + Shift")
            gsettings set org.cinnamon.desktop.input-sources xkb-options "['grp:alt_shift_toggle']" >> "$LOG_FILE" 2>&1
            echo "Встановлено Alt+Shift" >> "$LOG_FILE"
            ;;
        "Ctrl + Shift")
            gsettings set org.cinnamon.desktop.input-sources xkb-options "['grp:ctrl_shift_toggle']" >> "$LOG_FILE" 2>&1
            echo "Встановлено Ctrl+Shift" >> "$LOG_FILE"
            ;;
        "Win + Пробіл")
            gsettings set org.cinnamon.desktop.input-sources xkb-options "['grp:win_space_toggle']" >> "$LOG_FILE" 2>&1
            echo "Встановлено Win+Space" >> "$LOG_FILE"
            ;;
        *)
            gsettings set org.cinnamon.desktop.input-sources xkb-options "['grp:alt_shift_toggle']" >> "$LOG_FILE" 2>&1
            echo "Встановлено Alt+Shift за замовчуванням" >> "$LOG_FILE"
            ;;
    esac

    echo "80" ; echo "# Налаштування гарячих клавіш"
    echo "Налаштування гарячих клавіш" >> "$LOG_FILE"
    
    gsettings set org.cinnamon.desktop.keybindings custom-list "['custom0', 'custom1', 'custom2', 'custom3']" >> "$LOG_FILE" 2>&1
    
    path0="/org/cinnamon/desktop/keybindings/custom-keybindings/custom0"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path0/ name "'Згортання вікна'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path0/ command "'.local/bin/minimize-safe.sh'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path0/ binding "['<Super>h']" >> "$LOG_FILE" 2>&1

    gsettings set org.cinnamon.desktop.keybindings looking-glass-keybinding "['unbound']" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.media-keys screensaver "['<Super>l', '<Control><Alt>l']" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.media-keys area-screenshot "['<Shift>Print', '<Super><Shift>s']" >> "$LOG_FILE" 2>&1

    gsettings set org.cinnamon.desktop.keybindings.media-keys terminal "['<Super>r', '<Control><Alt>t']" >> "$LOG_FILE" 2>&1

    path1="/org/cinnamon/desktop/keybindings/custom-keybindings/custom1"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path1/ name "'CopyQ History'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path1/ command "'copyq menu'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path1/ binding "['<Super>v']" >> "$LOG_FILE" 2>&1

    path2="/org/cinnamon/desktop/keybindings/custom-keybindings/custom2"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path2/ name "'Запустити монітор ресурсів'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path2/ command "'flatpak run io.missioncenter.MissionCenter'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path2/ binding "['<Control>Escape', '<Shift>Escape', '<Control><Shift>Escape']" >> "$LOG_FILE" 2>&1

    path3="/org/cinnamon/desktop/keybindings/custom-keybindings/custom3"
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path3/ name "'Аварійне закриття вікна'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path3/ command "'.local/bin/kill-safe.sh'" >> "$LOG_FILE" 2>&1
    gsettings set org.cinnamon.desktop.keybindings.custom-keybinding:$path3/ binding "['<Control><Alt>Page_Down']" >> "$LOG_FILE" 2>&1

    echo "85" ; echo "# Створення ярликів на робочому столі"
    echo "Створення ярликів" >> "$LOG_FILE"

    USER_DESKTOP=$(xdg-user-dir DESKTOP)
    echo "Шлях до робочого столу: $USER_DESKTOP" >> "$LOG_FILE"

    cat << EOF > "$USER_DESKTOP/telegram.desktop"
[Desktop Entry]
Version=1.0
Name=Telegram
Comment=Telegram
Exec=/opt/Telegram/Updater
Icon=telegram
Terminal=false
Type=Application
Categories=Network;
EOF

    if [ -f /usr/share/applications/vesktop.desktop ]; then
        cp /usr/share/applications/vesktop.desktop "$USER_DESKTOP/"
    fi

    cat << EOF > "$USER_DESKTOP/bottles.desktop"
[Desktop Entry]
Name=Bottles
Comment=Запуск програм з Windows
Exec=flatpak run com.usebottles.bottles
Icon=com.usebottles.bottles
Terminal=false
Type=Application
Categories=Utility;
EOF

    chmod +x "$USER_DESKTOP"/*.desktop >> "$LOG_FILE" 2>&1
    
    for shortcut in "$USER_DESKTOP"/*.desktop; do
        gio set "$shortcut" metadata::trusted yes >> "$LOG_FILE" 2>&1
    done

    echo "100" ; echo "# Налаштування завершено"
    echo "Налаштування завершено" >> "$LOG_FILE"
    sleep 2
) | zenity --progress --title="Фінальне налаштування" --text="Ініціалізація..." --percentage=0 --auto-close --no-cancel --width=450

echo "Відновлення робочого столу..." >> "$LOG_FILE"
gsettings set org.nemo.desktop show-desktop-icons true >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop computer-icon-visible true >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop trash-icon-visible true >> "$LOG_FILE" 2>&1

gsettings set org.cinnamon.desktop.background picture-options 'zoom' >> "$LOG_FILE" 2>&1
gsettings set org.cinnamon panels-autohide "['1:false', '2:false']" >> "$LOG_FILE" 2>&1

echo "Налаштування дозволів для Bottles..." >> "$LOG_FILE"
flatpak override --filesystem="~/.local/share/Steam" com.usebottles.bottles >> "$LOG_FILE" 2>&1
flatpak override --filesystem="~/.steam" com.usebottles.bottles >> "$LOG_FILE" 2>&1

echo "Налаштування Swap (12GB)..." >> "$LOG_FILE"

sudo swapoff -a >> "$LOG_FILE" 2>&1

sudo fallocate -l 12G /swapfile >> "$LOG_FILE" 2>&1
sudo chmod 600 /swapfile >> "$LOG_FILE" 2>&1
sudo mkswap /swapfile >> "$LOG_FILE" 2>&1
sudo swapon /swapfile >> "$LOG_FILE" 2>&1

echo "Налаштування зовнішнього вигляду..." >> "$LOG_FILE"

gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Aqua' >> "$LOG_FILE" 2>&1
gsettings set org.cinnamon.theme name 'Mint-Y-Dark-Aqua' >> "$LOG_FILE" 2>&1
gsettings set org.cinnamon.desktop.interface icon-theme 'Papirus' >> "$LOG_FILE" 2>&1
gsettings set org.nemo.desktop desktop-layout 'true::true' >> "$LOG_FILE" 2>&1

sudo rm -f /usr/share/glib-2.0/schemas/99-custom-mint.gschema.override >> "$LOG_FILE" 2>&1
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/ >> "$LOG_FILE" 2>&1

echo "Знищення тимчасових правил sudoers..." >> "$LOG_FILE"
sudo rm -f /etc/sudoers.d/99-phase2-nopasswd >> "$LOG_FILE" 2>&1
sudo rm -f /etc/lightdm/lightdm.conf.d/99-phase2-autologin.conf >> "$LOG_FILE" 2>&1

nohup mintupdate-launcher >/dev/null 2>&1 &

nohup mintwelcome >/dev/null 2>&1 &

echo "Видалення скрипта Phase 2..." >> "$LOG_FILE"
rm -f "$HOME/.config/autostart/phase2.desktop" >> "$LOG_FILE" 2>&1

echo "Перезапуск оболонки Cinnamon..." >> "$LOG_FILE"
nohup cinnamon --replace > /dev/null 2>&1 & disown

echo "Роботу завершено" >> "$LOG_FILE"
exit 0


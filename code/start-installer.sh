#!/bin/bash
# /etc/skel/.local/bin/start-installer.sh

if [ -d /cdrom ]; then
    gsettings set org.cinnamon.sounds login-enabled false 2>/dev/null
    gsettings set com.linuxmint.mintwelcome show-at-login false 2>/dev/null

    echo "ubiquity ubiquity/use_nonfree boolean true" | sudo debconf-set-selections

    # echo "ubiquity ubiquity/reboot boolean false" | sudo debconf-set-selections

    echo "ubiquity ubiquity/success_command string cp /usr/local/bin/target-setup.sh /target/tmp/ && in-target bash /tmp/target-setup.sh" | sudo debconf-set-selections

    sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME sh -c 'WEBKIT_DISABLE_COMPOSITING_MODE=1 ubiquity gtk_ui' &
    UBI_PID=$!

    while true; do
        if ! kill -0 $UBI_PID 2>/dev/null; then exit 0; fi
        
        WID=$(xdotool search --onlyvisible --class "ubiquity" | head -n 1)
        if [ -n "$WID" ]; then
            sleep 0.5
            xdotool windowactivate $WID
            break
        fi
        sleep 0.5
    done

    wait $UBI_PID

    echo "Роботу інсталятора завершено"
fi
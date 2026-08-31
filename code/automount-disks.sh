#!/bin/bash
# /etc/skel/.local/bin/automount-disks.sh

sleep 5

MOUNTED=false

DISKS=$(lsblk -P -o NAME,TYPE,FSTYPE,MOUNTPOINT,PARTTYPE,LABEL | \
    grep 'TYPE="part"' | \
    grep -v 'FSTYPE=""' | \
    grep -v 'FSTYPE="swap"' | \
    grep -v 'FSTYPE="vfat"' | \
    grep 'MOUNTPOINT=""' | \
    grep -viE 'PARTTYPE="(de94bba4-06d1-4d40-a16a-bfd50179d6ac|27)"' | \
    grep -viE 'LABEL=".*(recovery|відновлення|восстановление).*"' | \
    grep -o 'NAME="[^"]*"' | cut -d'"' -f2)

for dev in $DISKS; do
    if udisksctl mount -b "/dev/$dev" --no-user-interaction; then
        MOUNTED=true
    fi
done

if [ "$MOUNTED" = true ]; then
    sleep 2
    nemo-desktop -q
    nohup nemo-desktop >/dev/null 2>&1 & disown
fi

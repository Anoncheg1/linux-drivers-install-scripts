#!/bin/bash
# For: git@github.com:Anoncheg1/88x2bu-20210702.git

backup_or_restore() {
    local file="$1"
    local backup="${file}.back"

    if [ -e "$backup" ]; then
        cp "$backup" "$file"
    else
        cp "$file" "$backup"
    fi
}

restore() {
    local file="$1"
    local backup="${file}.back"
    cp "$backup" "$file"
}


RTL=rtl8822b # rtl8812au
SOURCES_LOCATION="/usr/local/src/"
FOLDER=88x2bu-20210702
CONF_MOD=CONFIG_RTL8822BU
OLD_DRIVER=rtw88
parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"

rm -r "/usr/src/linux/drivers/net/wireless/realtek/${RTL}"
sed -i '$d' "/usr/src/linux/drivers/net/wireless/realtek/${RTL}/Makefile"
restore "$parentMakefile"
restore "$parentKconfig"
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"

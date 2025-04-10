#!/bin/bash

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


RTL=rtk_wifi_driver_rtl8822ce # directory
DRIVER_TAR="/usr/share/rtl8822ce-driver/rtl8822ce-driver.tar.gz"
CONF_MOD=CONFIG_RTL8822CE
OLD_DRIVER=rtw88
parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"
driverDir="/usr/src/linux/drivers/net/wireless/realtek/${RTL}"

rm -rf "/usr/src/linux/drivers/net/wireless/realtek/${RTL}" &>/dev/null
restore "$parentMakefile"
restore "$parentKconfig"
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"

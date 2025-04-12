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

RTL=rtl88x2ce-dkms # directory
DRIVER_TAR="/usr/share/rtl8822ce-driver/rtl8822ce-driver.tar.gz"
CONF_MOD=CONFIG_RTL8822CE
OLD_DRIVER=rtw88
parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"
driverDir="/usr/src/linux/drivers/net/wireless/realtek/${RTL}"
# mkdir -p "/lib/modules/$(uname -r)/build"
# mkdir -p "/lib/modules/$(cat /usr/src/linux/include/config/kernel.release)/build" # gentoo way

# - Add driver to Kernel source tree

rm -r "$driverDir" &> /dev/null

mkdir "$driverDir"
tar xpf "$DRIVER_TAR" -C "$driverDir"

# - fix line in Makefile of driver
sed -i "s/export ${CONF_MOD} = m/export ${CONF_MOD} = y/" "$driverDir"/Makefile

# - add line to parent Makefile to our folder
backup_or_restore "$parentMakefile"
echo 'obj-$('${CONF_MOD}')		+= '"${RTL}/" >> "$parentMakefile"

# - parent Kconfig - add section to Kconfig with path to our Kconfig
backup_or_restore "$parentKconfig"
sed -i '$d' "$parentKconfig" # remove last line
{
    echo "source \"drivers/net/wireless/realtek/${RTL}/Kconfig\""
    echo
    echo 'endif # WLAN_VENDOR_REALTEK'
} >> "$parentKconfig"

# - remove rtw88
backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"
echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"

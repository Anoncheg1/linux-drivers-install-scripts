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

# mkdir -p "/lib/modules/$(uname -r)/build"
# mkdir -p "/lib/modules/$(cat /usr/src/linux/include/config/kernel.release)/build" # gentoo way

# - Add driver to Kernel source tree
rm -r /usr/src/linux/drivers/net/wireless/realtek/${RTL} &> /dev/null
cp -r ${SOURCES_LOCATION}${FOLDER} /usr/src/linux/drivers/net/wireless/realtek/${RTL}
# - fix line in Makefile of driver
sed -i "s/export ${CONF_MOD} = m/export ${CONF_MOD} = y/" /usr/src/linux/drivers/net/wireless/realtek/${RTL}/Makefile

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

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

incremental_backup() {
    local file="$1"
    local base_name="${file}.back"
    local i=0

    while [ -f "${base_name}.${i}" ]; do
        ((i++))
    done

    cp "$file" "${base_name}.${i}"
    echo "Backup created as ${base_name}.${i}"
}

insert_lines_to_config() {
    if [ -z "$1" ] ; then echo no \$1; return 1 ; fi
    if [ -z "$2" ] ; then echo no \$2; return 1 ; fi
    if [ -z "$3" ] ; then echo no \$3; return 1 ; fi
    file=$1
    after_what=$2 # '^source' for Kconfig, '^obj-$(CONFIG' for Makefile.
    insert_lines=$3

    # Get the first line of insert_lines
    first_insert_line=$(echo "$insert_lines" | head -n 1)

    # Check if the first line of insert_lines exists in the file
    if grep -q "^$first_insert_line$" "$file"; then
        echo "First line of insert_lines already exists in $file, skipping modification."
        return 0
    fi

    # Find the line number of the last line matching the pattern
    last_match_line=$(grep -n "$after_what" "$file" | tail -n 1 | cut -d ':' -f 1)

    if [ -n "$last_match_line" ]; then
        # Insert lines after this point
        tmp_file=$(mktemp --tmpdir=/tmp)
        head -n $((last_match_line)) "$file" > "$tmp_file"
        echo "$insert_lines" >> "$tmp_file"
        tail -n +$((last_match_line + 1)) "$file" >> "$tmp_file"
        mv "$tmp_file" "$file"
        echo "Successfully inserted lines into $file."
    else
        echo "No lines matching '$after_what' found in $file."
    fi
}

RTL=rtl8822b # rtl8812au
DRIVER_TAR="/usr/share/rtl88x2bu-driver/rtl88x2bu-driver.tar.gz"
CONF_MOD=CONFIG_RTL8822BU
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

# - Makefile: add line to parent
# - add line to parent Makefile to our folder
# backup_or_restore "$parentMakefile"
# echo 'obj-$('${CONF_MOD}')		+= '"${RTL}/" >> "$parentMakefile"
incremental_backup "$parentMakefile"
insert_after="^obj-"
lines_to_insert=$(printf "obj-\$(${CONF_MOD})		+= %s/\n" "${RTL}")
insert_lines_to_config "$parentMakefile" "$insert_after" "$lines_to_insert"

# - Kconfig - add section to parent Kconfig with path to our Kconfig
# backup_or_restore "$parentKconfig"
# sed -i '$d' "$parentKconfig" # remove last line
# {
#     echo "source \"drivers/net/wireless/realtek/${RTL}/Kconfig\""
#     echo
#     echo 'endif # WLAN_VENDOR_REALTEK'
# } >> "$parentKconfig"

insert_after="^source"
lines_to_insert="source \"drivers/net/wireless/realtek/${RTL}/Kconfig\"
"
incremental_backup "$parentKconfig"
insert_lines_to_config "$parentKconfig" "$insert_after" "$lines_to_insert"


# - remove rtw88
backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
backup_or_restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"
echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
echo "" > "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"

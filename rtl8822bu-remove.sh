#!/bin/bash
# For: git@github.com:Anoncheg1/88x2bu-20210702.git

restore() {
    local file="$1"
    local backup="${file}.back"
    cp "$backup" "$file"
}

remove_inserted_lines() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Error: Missing argument(s)."
        return 1
    fi

    local file="$1"
    local insert_lines="$2"

    # Get key details about insert_lines
    local first_insert_line=$(echo "$insert_lines" | head -n 1)
    echo first_insert_line "$first_insert_line"
    local total_insert_lines=$(echo "$insert_lines" | wc -l)
    echo total_insert_lines $total_insert_lines

    # Find and remove lines
    local line_number=$(grep -n "^$first_insert_line$" "$file" | head -n 1 | cut -d ':' -f 1)
    if [ -n "$line_number" ]; then
        sed -i "$((line_number)),$((line_number + total_insert_lines - 1))d" "$file"
        echo "Lines removed from $file."
    else
        echo "Lines not found in $file."
    fi
}


RTL=rtl8822b # directory
SOURCES_LOCATION="/usr/local/src/"
FOLDER=88x2bu-20210702
CONF_MOD=CONFIG_RTL8822BU
OLD_DRIVER=rtw88
parentMakefile="/usr/src/linux/drivers/net/wireless/realtek/Makefile"
parentKconfig="/usr/src/linux/drivers/net/wireless/realtek/Kconfig"

rm -rf "/usr/src/linux/drivers/net/wireless/realtek/${RTL}" &>/dev/null

# - Makefile
lines_to_insert=$(printf "obj-\$(${CONF_MOD})		+= %s/\n" "${RTL}")
remove_inserted_lines "$parentMakefile" "$lines_to_insert"
# - Kconfig
lines_to_insert="source \"drivers/net/wireless/realtek/${RTL}/Kconfig\"
"
remove_inserted_lines "$parentKconfig" "$lines_to_insert"

# - restore OLD_DRIVER=rtw88
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Kconfig"
restore "/usr/src/linux/drivers/net/wireless/realtek/${OLD_DRIVER}/Makefile"

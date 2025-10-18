#!/bin/bash

# Usage: ./scan_file_system.sh ~/temp 
# where temp contains only one directory named as the root mnagement group

scan_fs() {
    local parent="$1"
    local path="$2"

    # Find immediate subdirectories
    echo =============== parent directory: $parent ===============
    local children=()
    while IFS= read -r -d '' child; do
        children+=("$(basename "$child")")
		echo $(basename "$child")
    done < <(find "$path/$parent" -mindepth 1 -maxdepth 1 -type d -print0)

    for child in "${children[@]}"; do
        scan_fs "$child" "$path/$parent"
    done
}


# Check for root directory argument
if [ -z "$1" ]; then
    echo "Usage: $0 <root_directory>"
    exit 1
fi

ROOT_DIR=$(basename "$1")
ROOT_PATH=$(dirname "$1")

scan_fs "$ROOT_DIR" "$ROOT_PATH"

# Print the associative array
# for key in "${!DIR_TREE[@]}"; do
#     echo "$key: ${DIR_TREE[$key]}"
# done

# echo ${DIR_TREE[rzand-li]} -> to see children of rzand-li
# to pring keys echo ${!DIR_TREE[*]}
# to print values echo ${DIR_TREE[@]}
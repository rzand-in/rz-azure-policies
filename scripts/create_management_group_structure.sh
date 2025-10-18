#!/bin/bash

# Usage: ./dir_tree_to_array.sh <root_directory>

declare -A DIR_TREE # Associative array to hold the directory tree, see https://rednafi.com/misc/associative-arrays-in-bash/

build_tree() {
    local parent="$1"
    local path="$2"

    # Find immediate subdirectories
    local children=()
    while IFS= read -r -d '' child; do
        children+=("$(basename "$child")")
    done < <(find "$path/$parent" -mindepth 1 -maxdepth 1 -type d -print0)

    DIR_TREE["$parent"]="${children[*]}"

    for child in "${children[@]}"; do
        build_tree "$child" "$path/$parent"
    done
}

# Check for root directory argument
if [ -z "$1" ]; then
    echo "Usage: $0 <root_directory>"
    exit 1
fi

ROOT_DIR=$(basename "$1")
ROOT_PATH=$(dirname "$1")

build_tree "$ROOT_DIR" "$ROOT_PATH"

# Print the associative array
for key in "${!DIR_TREE[@]}"; do
    echo "$key: ${DIR_TREE[$key]}"
done

# echo ${DIR_TREE[rzand-li]} -> to see children of rzand-li
# to pring keys echo ${!DIR_TREE[*]}
# to print values echo ${DIR_TREE[@]}
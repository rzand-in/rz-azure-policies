#!/bin/bash

# Usage: ./scan_file_system_and_create_management_groups.sh ~/temp 
# where temp contains only one directory named as the root mnagement group

# Thanks copilot for some assistance with the code 

# Variables declaration

# Thanks to: https://medium.com/@python-javascript-php-html-css/changing-text-color-in-bash-using-echo-command-adf32a6bc3b8
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
mg_count=0

# check if you are connected to azure
echo "Checking Azure connection..."
AZURE_USER=$(az account show --query user.name -o tsv) > /dev/null 2>&1
if [ "$AZURE_USER" ]; then
    echo -e "${GREEN}You are connected to Azure as user $AZURE_USER.${NC}"
else
    echo -e "${YELLOW}You are not connected to Azure. Please login using 'az login'.${NC}"
    exit 1
fi

# Scan file system and build the management groups tree
scan_fs() {
    local parent="$1"
    local path="$2"

    # Find immediate subdirectories
    echo =============== parent directory: $parent ===============
    local children=()
    while IFS= read -r -d '' child ; do
        children+=("$(basename "$child")")
        # echo "Parent mg $parent"
        if [ $mg_count -eq 0 ]; then
            echo -e "${GREEN}Creating ${YELLOW}root ${GREEN}management group ${YELLOW}$(basename "$child")${NC}"
            az account management-group create --name $(basename "$child") > /dev/null 2>&1
        else
            echo -e "${GREEN}Creating management group ${YELLOW}$(basename "$child") ${GREEN}under parent${YELLOW} $parent${NC}"
            az account management-group create --name $(basename "$child") --parent $parent > /dev/null 2>&1
        fi
        mg_count=$((mg_count + 1))
    done < <(find "$path/$parent" -mindepth 1 -maxdepth 1 -type d -print0)
    # The < <(...) syntax is called process substitution. It allows the output of the find command to be fed directly into the loop as input.

    for child in "${children[@]}"; do
        scan_fs "$child" "$path/$parent"
    done
}

# Check for root directory argument
if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <root_directory>${NC}"
    exit 1
fi

ROOT_DIR=$(basename "$1")
ROOT_PATH=$(dirname "$1")

scan_fs "$ROOT_DIR" "$ROOT_PATH"
echo -e "${BLUE}Created $mg_count management groups.${NC}"
#!/bin/bash

# Define the tree structure: keys are parent directories, values are space-separated children
declare -A MG_TREE
MG_TREE[rzand-li]="platform landingzones decomissioned sandbox"
MG_TREE[platform]="identity connectivity security management"
# MG_TREE[landingzones]="active passive"
# MG_TREE[decomissioned]=""
# MG_TREE[sandbox]="dev test"
# MG_TREE[identity]="onprem cloud"
# Add more as needed

create_tree() {
    local parent=$1
    local path=$2

    mkdir -p "$path/$parent"
    for child in ${MG_TREE[$parent]}; do
        create_tree "$child" "$path/$parent"
    done
}

# Start from the root (change 'root' to your desired top-level directory name)
create_tree "rzand-li" "$(pwd)"

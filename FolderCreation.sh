#!/bin/bash

# FolderCreation.sh
# Script to create department folders with correct permissions and ownership

BASE_DIR="/EmployeeData"
departments=("HR" "IT" "Finance" "Executive" "Administrative" "Call Centre")
created_folders=0

mkdir -p "$BASE_DIR"

for dept in "${departments[@]}"; do
    folder="$BASE_DIR/$dept"
    mkdir -p "$folder"

    # Permissions
    if [[ "$dept" == "HR" || "$dept" == "Executive" ]]; then
        chmod -R 760 "$folder"
    else
        chmod -R 754 "$folder"
    fi

    # Sanitize group name (replace space with underscore)
    group_name="${dept// /_}"

    # Create group if it doesn't exist
    if ! getent group "$group_name" > /dev/null; then
        groupadd "$group_name"
    fi

    # Assign group ownership
    chown root:"$group_name" "$folder"

    ((created_folders++))
done

echo "$created_folders folders were created under $BASE_DIR"


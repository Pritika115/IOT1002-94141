
#!/bin/bash

# Variables to keep track of the number of users and groups added
new_users_count=0
new_groups_count=0

# Path to the input CSV file
input_file="/home/Pritika/EmployeeNames.csv"

# Check if the input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file $input_file not found."
    exit 1
fi

# Proper header for the script output
echo "Starting User and Group Creation Utility..."
echo "Processing file: $input_file"
echo "-------------------------------------------------"

# Read the file line by line, skipping empty lines
while IFS=',' read -r first_name last_name department; do
    # Skip empty or malformed lines
    if [[ -z "$first_name" || -z "$last_name" || -z "$department" ]]; then
        echo "Warning: Skipping malformed or empty line."
        continue
    fi

    # Create the username (first initial + first 7 characters of last name, lowercase)
    username="${first_name:0:1}${last_name:0:7}"
    username=$(echo "$username" | tr '[:upper:]' '[:lower:]') # Convert to lowercase

    # Check if the user already exists
    if id -u "$username" >/dev/null 2>&1; then
        echo "Error: User $username already exists. Skipping..."
    else
        # Create the user with a home directory and full name as a comment
        sudo useradd -m -c "$first_name $last_name" "$username"
        if [[ $? -eq 0 ]]; then
            echo "User $username created successfully."
            ((new_users_count++))
        else
            echo "Error: Failed to create user $username. Skipping..."
            continue
        fi
    fi

    # Check if the group (department) exists
    if getent group "$department" >/dev/null 2>&1; then
        echo "Error: Group $department already exists."
    else
        # Create the group
        sudo groupadd "$department"
        if [[ $? -eq 0 ]]; then
            echo "Group $department created successfully."
            ((new_groups_count++))
        else
            echo "Error: Failed to create group $department. Skipping..."
            continue
        fi
    fi

    # Add the user to the group (check if already in group)
    if id -nG "$username" | grep -qw "$department"; then
        echo "Error: User $username is already a member of group $department. Skipping..."
    else
        sudo usermod -g "$department" "$username"
        if [[ $? -eq 0 ]]; then
            echo "User $username added to group $department successfully."
        else
            echo "Error: Failed to add user $username to group $department. Skipping..."
        fi
    fi

done < "$input_file"

# Output the final summary
echo "-------------------------------------------------"
echo "Summary of Operations:"
echo "Total new users added: $new_users_count"
echo "Total new groups added: $new_groups_count"
echo "-------------------------------------------------"
echo "User and Group Creation Utility completed."
exit 0 

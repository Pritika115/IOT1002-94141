#!/bin/bash

# Set log file name
DATE=$(date +%Y-%m-%d)
LOG_FILE="$HOME/ProcessUsageReport-$DATE"

# CSV file for employee departments
EMPLOYEE_CSV="EmployeeNames.csv"

# Function to get the department from the CSV file
get_department() {
  username="$1"
  department=$(grep "^$username," "$EMPLOYEE_CSV" | cut -d',' -f3)
  echo "$department"
}

# Find the top 5 processes by CPU usage
top_processes=$(ps -eo user,pid,%cpu,etime,comm --sort=-%cpu | head -n 6 | tail -n 5)

# Display the top processes to the user
echo "Top 5 Processes by CPU Usage:"
echo "$top_processes"

# Ask the user for confirmation
read -p "Do you want to kill non-root processes? (y/n): " confirm

# Check if the user confirmed
if [[ "$confirm" == "y" ]]; then
  killed_count=0
  echo "Killing non-root processes..."

  # Loop through the top processes
  while read -r user pid cpu etime command; do
    # Skip the header line
    if [[ "$user" == "USER" ]]; then
      continue
    fi

    # Check if the user is not root
    if [[ "$user" != "root" ]]; then
      # Get the start time
      start_time=$(ps -p "$pid" -o lstart=)
      # Get the department from the CSV
      department=$(get_department "$user")

      # Kill the process
      kill -SIGKILL "$pid"
      kill_time=$(date +%Y-%m-%d_%H:%M:%S)

      # Log the details
      echo "Username: $user" >> "$LOG_FILE"
      echo "PID: $pid" >> "$LOG_FILE"
      echo "Start Time: $start_time" >> "$LOG_FILE"
      echo "Kill Time: $kill_time" >> "$LOG_FILE"
      echo "Department: $department" >> "$LOG_FILE"
      echo "------------------------" >> "$LOG_FILE"

      # Increment the killed count
      ((killed_count++))
    fi
  done <<< "$top_processes"

  # Display the number of processes killed
  echo "Total processes killed: $killed_count"
else
  echo "No processes were killed."
fi

echo "Process details logged to: $LOG_FILE"


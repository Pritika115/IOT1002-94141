#!/bin/bash

# Define the IT group
IT_GROUP="IT"

# Get a list of IT users from the CSV file
IT_USERS=$(awk -F',' '$2 == "IT" {print $1}' EmployeeNames.csv)

# Counter for IT users
USER_COUNT=0

# Allow IT users to access the internet
for user in $IT_USERS; do
    sudo iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner "$user" -j ACCEPT
    ((USER_COUNT++))
done

# Allow traffic to the local web server
sudo iptables -A OUTPUT -p tcp --dport 443 -d 192.168.2.3 -j ACCEPT

# Block all other HTTP/HTTPS traffic
sudo iptables -A OUTPUT -p tcp --dport 80 -j DROP
sudo iptables -A OUTPUT -p tcp --dport 443 -j DROP

# Drop access to special ports
sudo iptables -t filter -A OUTPUT -p tcp --dport 8003 -j DROP
sudo iptables -t filter -A OUTPUT -p tcp --dport 1979 -j DROP

# Display the number of users granted internet access
echo "Number of IT users granted internet access: $USER_COUNT"
 

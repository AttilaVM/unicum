#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "No arguments provided"
    echo "Usage: ./get_location.sh <ip_address>"
    exit 1
fi

# API endpoint
url="http://ip-api.com/json/$1"

# Send GET request and get location info
location_info=$(curl -s $url)

# Print the location info
echo $location_info | jq

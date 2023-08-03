#!/bin/bash
set -euo pipefail

limit=${1:-"10"}

failed_ssh_auths=$(grep "Failed password" /var/log/auth.log | grep sshd)

failing_ips=$(echo "$failed_ssh_auths" \
    | grep -oP '(?<=from )(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n "$limit"
)

echo 'count;country;region_name;city;isp;lat;lon;ip'
while read -r count ip; do
    location_data=$(ip2loc.sh "$ip"  | jq -r '[.country, .regionName, .city, .isp, .lat, .lon] | join(";")' )
    echo "${count};${location_data};$ip"
done < <(echo "$failing_ips")

#!/bin/bash
set -euo pipefail

network=${1:? "A path must be defined as the first varialbe"}

set +e
echo "$network" | grep -P '^([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2}$' &> /dev/null
exit_status=$?
set -e

if [[ ! $exit_status -eq 0 ]]; then
    echo "invalid  IPv4 CIDR notationa ${network}" >&2
    exit 1
else
    echo 'valid  IPv4 CIDR notationa' >&2
    exit 0
fi
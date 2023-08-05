#!/bin/bash
# Enusres that a given user exists
set -euo pipefail

username="$1"
flags="$2"

if ! id -u "$username" >/dev/null 2>&1; then
    useradd $flags $username
    echo 'changed'
else
    echo 'unchanged'
fi
#!/bin/bash
set -euo pipefail

msg=${1:? "message"}

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "${timestamp} $msg" | tee --append "$LOGFILE" >&2
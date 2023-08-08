#!/bin/bash
set -euo pipefail

name="$1"

./easyrsa gen-req "$name" nopass
./easyrsa sign-req client "$name"

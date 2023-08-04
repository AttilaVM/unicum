#!/bin/bash
set -euo pipefail

pki_dir="$1"

if [ -d "$pki_dir" ]; then
    echo 'unchanged'
    exit 0
fi


export EASYRSA="$pki_dir"
make-cadir "$pki_dir"
cd "$pki_dir" 

export EASYRSA_VARS_FILE="$(pwd)/vars"

cat >> "$EASYRSA_VARS_FILE" <<EOF
set_var EASYRSA_ALGO            ${EASYRSA_ALGO}
set_var EASYRSA_CURVE           ${EASYRSA_ALGO_PARAM}
set_var EASYRSA_CA_EXPIRE       ${EASYRSA_CA_EXPIRE}
set_var EASYRSA_CERT_EXPIRE     ${EASYRSA_CERT_EXPIRE}
EOF

export EASYRSA_BATCH=1

./easyrsa --use-algo=ed --curve=ed25519 init-pki
./easyrsa build-ca nopass

log.sh 'CHANGE: easyrsa PKI created'
echo 'changed'
exit 0
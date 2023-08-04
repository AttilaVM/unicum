#!/bin/bash
set -euo pipefail

pki_dir="$1"
servername="$2"

key_dst_path="/etc/openvpn/server/${servername}.key"
crt_dst_path="/etc/openvpn/server/${servername}.crt"

if [ -f "$key_dst_path" ]; then
    echo 'unchanged'
    exit 0
fi


cd "$pki_dir" 
export EASYRSA="$pki_dir"
export EASYRSA_VARS_FILE="$(pwd)/vars"

export EASYRSA_BATCH=1

# install CA certificate
cp "${pki_dir}/pki/ca.crt"  /etc/openvpn/server/ca.crt

# install server certificate
export EASYRSA_REQ_CN=${servername}
./easyrsa gen-req ${servername} nopass
./easyrsa sign-req server ${servername}

cp "${pki_dir}/pki/private/${servername}.key" "${key_dst_path}"
cp "${pki_dir}/pki/issued/${servername}.crt" "${crt_dst_path}"
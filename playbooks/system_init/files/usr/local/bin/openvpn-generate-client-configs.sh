#!/bin/bash
set -euo pipefail

ovpn_config_template_path="$1"

if [ ! -e "$ovpn_config_template_path" ]; then
    echo 'ovpn template does not exists' >&2
fi

if [ ! -f "$ovpn_config_template_path" ]; then
    echo 'ovpn template is not a regular file' >&2
fi

if [ ! -f pki/ca.crt ]; then
    echo 'you are not in the root of a easyrsa CA root directory' >&2
fi

cacrt_pem=$(awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "pki/ca.crt")

export CACERT_PEM="$cacrt_pem"

tls_auth_pem=$(awk '/-----BEGIN OpenVPN Static key V1-----/,/-----END OpenVPN Static key V1-----/' "pki/ca.crt" /etc/openvpn/server/ta.key)

export TLS_AUTH_KEY="$tls_auth_pem"

export SERVER_IP=$(ip addr show eth0 | grep inet | awk '{ print $2; }' | cut -d/ -f1)

mkdir -p openvpn_client_configs

for full_file in pki/issued/*.crt; do
    filename=$(basename -- "$full_file")
    name="${filename%.crt}"
    crt_pem=$(awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' "pki/issued/${name}.crt")
    key_pem=$(awk '/-----BEGIN PRIVATE KEY-----/,/-----END PRIVATE KEY-----/' "pki/private/${name}.key")

    export CLIENT_CERT_PEM="$crt_pem"
    export CLIENT_KEY_PEM="$key_pem"

    < "$ovpn_config_template_path" envsubst > "./openvpn_client_configs/${name}.ovpn"

done

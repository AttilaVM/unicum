#!/bin/bash
set -euo pipefail

# package managment
apt update -y
apt upgrade -y

## Install utilities
apt install -y \
  neovim \
  tmux \
  tree \
  jq \
  python3 \
  ipython3 \
  python3-ipython \
  gnupg \
  curl \
  pass

## install admin tools
apt install -y \
  easy-rsa \
  nmap \
  iptables \
  ca-certificates \

## Install servicies
apt install -y \
  fail2ban \
  openvpn

## Install docker
## as described here: https://docs.docker.com/engine/install/ubuntu/

if [ ! -d /etc/apt/keyrings  ]; then
    install -m 0755 -d /etc/apt/keyrings
fi

if [ ! -f /etc/apt/keyrings/docker.gpg  ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
fi

if [ ! -f /etc/apt/sources.list.d/docker.list  ]; then
    source /etc/os-release
    cat << EOF > /etc/apt/sources.list.d/docker.list
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable
EOF
    apt update -y

    apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
fi
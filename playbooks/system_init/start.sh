#!/bin/bash
set -euo pipefail

playbook_name='system_init'

script_path=$(readlink -f "$0")
playbook_root=$(dirname "$script_path")

export PLAYBOOK_ROOT="$playbook_root"
export PATH="$PATH:$PLAYBOOK_ROOT/tasks"

# create logfile
logdir="/var/log/ansible_at_home/"
logfile="${logdir}/${playbook_name}.log"

mkdir -p "${logdir}"

export LOGFILE="$logfile"

# log errors
catch() {
  log.sh "ERROR $1 occurred at line: $2"
}
trap 'catch $? $LINENO' ERR

log.sh "START: $playbook_name"


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
  python3-ipython

## install admin tools
apt install -y \
  easy-rsa \
  nmap \
  iptables

## Install servicies
apt install -y \
  fail2ban \
  openvpn
  

# System configuration

## Ensure backup directory for old system config files
backup_dir="$(ensure-backup-dir.sh $playbook_name)"
export BACKUP_DIR="$backup_dir"


## Configure ssh daemon

state_sshd=$(ensure-file.sh etc/ssh/sshd_config 644 'sshd -t')

if [ "$state_sshd" == "changed" ]; then
  log.sh 'restart sshd'
  systemctl restart ssh.service
fi

## Configure fail2ban against ssh brute force attacks

state_fail2ban=$(ensure-file.sh etc/fail2ban/fail2ban.local 644 'fail2ban-client --test')
state_jail=$(ensure-file.sh etc/fail2ban/jail.local.template 644 'fail2ban-client --test')

if [ "$state_jail" == "changed" ] || [ "$state_fail2ban" == "changed" ] ; then
  log.sh 'restart fail2ban'
  systemctl restart fail2ban.service
fi

systemctl start fail2ban.service
systemctl enable fail2ban.service

## Create public key infrastructure

task-create-pki.sh "${EASYRSA_DIR}"

## Create and install certificates OpenVPN

ensure-command.sh \
 'openvpn --genkey tls-auth /etc/openvpn/server/ta.key' \
 'test -f /etc/openvpn/server/ta.key'

ensure-command.sh \
  'openssl dhparam -out /etc/openvpn/server/dh.pem 2048' \
  'test -f /etc/openvpn/server/dh.pem'

task-install-openvpn-certificate.sh "${EASYRSA_DIR}" ${OPENVPN_NAME}

state_openvpn=$(ensure-file.sh etc/openvpn/server.conf 644 'true')
systemctl enable openvpn.service

if [ "$state_openvpn" == "changed" ]; then
  log.sh 'restart openvpn'
  systemctl restart openvpn.service
else
  systemctl start openvpn.service
fi

ensure-file.sh etc/openvpn/template_client.conf 644 'true'

## Install scripts

ensure-file.sh usr/local/bin/openvpn-generate-client-configs.sh 755 'true' > /dev/null
ensure-file.sh usr/local/bin/ip2loc.sh 755 'true' > /dev/null
ensure-file.sh usr/local/bin/ssh-attack-summary.sh 755 'true' > /dev/null

log.sh "STOP: $playbook_name"


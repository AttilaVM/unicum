#!/bin/bash
# Enusres that a backup directory exists for a playbook with a given name.
# Backup directories are seperated by playbook names and enumerated
#
# parameters:
# $1 is the name of playbook requesting the backup directory
#
# examples:
# $ ensure-backup-dir.sh my_playbook
# >>> /root/backup/my_playbook/0001-my_playbook
# $ ensure-backup-dir.sh my_playbook
# >>> /root/backup/my_playbook/0002-my_playbook

set -euo pipefail

name=${1:? "name of the playbook requesting a backup directory"}

base_dir="$BACKUP_ROOT/$name"

mkdir -p "$base_dir"

backup_dir="${base_dir}/0001-${name}"



backup_dirs=$(ls -d ${base_dir}/[0-9]* 2> /dev/null || echo '')

if [ -z "$backup_dirs" ]; then
    mkdir "$backup_dir";
    log.sh "backup dir created at: $backup_dir";
    echo $backup_dir
    exit 0
fi

last_dir=$(echo "$backup_dirs" | sort -n -r | head -1)

num=$(echo $last_dir | grep -o -E '[0-9]+')
num=$(printf "%04d" $((10#$num + 1)))

backup_dir="${base_dir}/${num}-${name}"
mkdir $backup_dir

echo $backup_dir
#!/bin/bash
# Enusres that a given playbook file is copied or rendered under the correct system path and the original file is backed up. 
# Files with `.template` extensions will be rendered with `envsubst` other files will be copied.
#
# parameters:
# $1 is the path variable defining 2 paths. The first path define the source filef, which is relative from ./files directory in the given playbook directory
# the second path defines the destination on the system relative to the root `\`. E.G etc/hosts will copy the ./files/etc/hosts file into the
# /etc/hosts path of the system
# $2 is the check command if it fails then if possible (there was a file at the destination) the most recent backup of the
# destination is restored, otherwise the new file is deleted. However in all cases an error is returned if the check command fails
#
# examples
# $ ensure-file etc/hosts.template
# >>> # no output, side-effect only: the /etc/hosts file will be overriden by the rendering of a template from <current playbook/files/etc/hosts>

set -euo pipefail

path=${1:? "A path must be defined as the first varialbe"}
file_permision=${2:? "A file permision mode of the file in octal format such as 600"}
check_command=${3:? "a command which should check if the config file works, if no applicable just pass `true`"}

src="$PLAYBOOK_ROOT/files/$path"
dst="/$path"

# remove .template extension from destination path
src_extension="${src##*.}"
if [ "$src_extension" == "template" ]; then
    dst="${dst%.*}"
fi

# check arguments

if [ ! -e "$src" ]; then
    echo "source: $src does not exists" >&2
    exit 1
fi

if [ ! -f "$src" ]; then
    echo "source: $src is not regular file" >&2
    exit 1
fi

if [ -e "$dst" ] && [ ! -f "$dst" ]; then
    echo "destination: $dst is not regular file" >&2
    exit 1
fi

# stop if the 2 files are already the same
# in case of a template render a temporarly output
# to compare with the destination
if [ "$src_extension" == "template" ]; then
    temp_rendered_file=$(tempfile)
    # render to destination path
    < "$src" envsubst > "$temp_rendered_file"
    if diff -q "$temp_rendered_file" "$dst" > /dev/null; then
        log.sh "$dst won't change"
        rm "$temp_rendered_file"
        echo 'unchanged'
        chmod "$file_permision" "$dst"
        exit 0
    else
        rm "$temp_rendered_file"
    fi
# for ordinary files compare directly
else
    if diff -q "$src" "$dst" > /dev/null; then
        log.sh "$dst won't change"
        echo 'unchanged'
        chmod "$file_permision" "$dst"
        exit 0
    fi
fi


# backup original file if exists
if [ -f "$dst" ]; then
    dst_absolute_parent_path=$(readlink -f "$dst")
    dst_absolute_parent_dir=$(dirname "$dst_absolute_parent_path")
    dst_relative_parent_dir="${dst_absolute_parent_dir:1}"
    dst_filename=$(basename "$dst_absolute_parent_path")

    backup_dir="$BACKUP_DIR/$dst_relative_parent_dir"
    backup_path="$backup_dir/$dst_filename"

    mkdir -p "$backup_dir"

    cp "$dst_absolute_parent_path" "$backup_path"

    log.sh "$dst is backed up at $backup_path"
fi

# copy source to destination

# render template files with `envsubst`, othewise just copy.
if [ "$src_extension" == "template" ]; then
    # render to destination path
    < "$src" envsubst > "$dst"
    log.sh "$dst is rendered"
else
    cp "$src" "$dst"
    log.sh "$dst is copied"
fi

# If check command fails restore bacup
set +e
$check_command
exit_status=$?

if [[ ! $exit_status -eq 0 ]]; then

    if [ -z "${backup_path+defined}" ]; then
        log.sh "wrong config for $dst, no recent backup to restore"
        rm "$dst"
        echo 'unchanged'
        exit 1
    else
        log.sh "wrong config for $dst, restoring backup"
        cp "$backup_path" "$dst_absolute_parent_path"
        log.sh "backup restored, exiting"
        echo 'unchanged'
        exit 1
    fi
fi

chmod "$file_permision" "$dst"
echo 'changed'

set -e

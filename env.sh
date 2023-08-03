script_path=$(readlink -f "$0")
project_root=$(dirname "$script_path")

export PROJECT_ROOT="$project_root"

export PATH="$PROJECT_ROOT/ansible_at_home:$PATH"

# Set global playbook parameters
export BACKUP_ROOT=/root/backup

# each playbook will have its own logfile at /var/log/<playbook name>
# this LOGFILE is needed to test out Ansible At Home commands in
# standalone mode. 
export LOGFILE="$PROJECT_ROOT/test.log"

if [ -e "$PROJECT_ROOT/parameters.sh" ]; then
    source "${PROJECT_ROOT}/parameters.sh"
else 
    echo 'ERROR: missing parameters.sh. run `cp parameters.sh.example parameters.sh` and configure it'
fi

#!/bin/bash

set -e

echo "In generate_ansible_playbook.sh"

function alpha_only() {
    echo "$1" | tr -cd '[:alpha:]' | tr '[:upper:]' '[:lower:]'
}

echo -en "- name: Ensure hosts is up and running
  hosts: bitops_servers
  gather_facts: no
  tasks:
  - name: Wait for hosts to come up
    wait_for_connection:
      timeout: 300

- name: Ansible tasks
  hosts: bitops_servers
  become: true
  tasks:
" > $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml

# Adding docker cleanup task to playbook
if [[ $DOCKER_FULL_CLEANUP = true ]]; then
echo -en "
  - name: Docker Cleanup
    include_tasks: tasks/docker_cleanup.yml
" >> $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml
fi

# Adding app_pore cleanup task to playbook
if [[ $APP_DIRECTORY_CLEANUP = true ]]; then
echo -en "
  - name: EC2 Cleanup
    include_tasks: tasks/ec2_cleanup.yml
" >> $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml
fi

# Continue adding the defaults
echo -en "
  - name: Include install
    include_tasks: tasks/install.yml
  - name: Include fetch
    include_tasks: tasks/fetch.yml
    # Notes on why unmounting is required can be found in umount.yaml
  - name: Unmount efs
    include_tasks: tasks/umount.yml
" >> $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml
if [[ $(alpha_only "$AWS_EFS_CREATE") == true ]] || [[ $(alpha_only "$AWS_EFS_CREATE_HA") == true ]] || [[ $AWS_MOUNT_EFS_ID != "" ]]; then
echo -en "
  - name: Mount efs
    include_tasks: tasks/mount.yml
    when: mount_efs
" >> $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml
fi
echo -en "
  - name: Include start
    include_tasks: tasks/start.yml
" >> $GITHUB_ACTION_PATH/operations/deployment/ansible/playbook.yml
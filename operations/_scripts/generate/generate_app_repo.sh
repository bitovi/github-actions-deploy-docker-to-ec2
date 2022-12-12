#!/bin/bash

set -e


echo "In generate_app_repo.sh"
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

echo "Copying files from GITHUB_WORKSPACE ($GITHUB_WORKSPACE) to ops repo's Ansible deployment (${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/${GITHUB_REPO_NAME})"
mkdir -p "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/${GITHUB_REPO_NAME}"

TARGET_PATH="$GITHUB_WORKSPACE"
if [ -n "$APP_DIRECTORY" ]; then
    echo "APP_DIRECTORY: $APP_DIRECTORY"
    TARGET_PATH="${TARGET_PATH}/${APP_DIRECTORY}"
fi

cp -rf "$TARGET_PATH"/* "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/${GITHUB_REPO_NAME}/"

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

if [ -s "$TARGET_PATH/$REPO_ENV" ]; then
  echo "Copying checked in env file from repo to Ansible deployment path"
  cp "$TARGET_PATH/$REPO_ENV" "${GITHUB_ACTION_PATH}/operations/deployment/ansible/repo.env"
else
  echo "Checked in env file from repo is empty or couldn't be found"
fi
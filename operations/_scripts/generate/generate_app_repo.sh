#!/bin/bash

set -e


echo "In generate_app_repo.sh"
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

mkdir -p "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/{$GITHUB_REPO_NAME}"
cp -rf "$GITHUB_WORKSPACE"/* >> "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/{$REPO_NAME}"

echo "ls GITHUB_ACTION_PATH/operations/deployment/ansible/app/{$GITHUB_REPO_NAME}"
ls "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app/{$GITHUB_REPO_NAME}"

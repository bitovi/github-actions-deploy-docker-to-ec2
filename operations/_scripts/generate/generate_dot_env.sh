#!/bin/bash

set -e


echo "In generate_dot_env.sh"


GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')


echo "$DOT_ENV" >> "${GITHUB_ACTION_PATH}/operations/deployment/ansible/app.env"

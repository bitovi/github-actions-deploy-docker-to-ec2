#!/bin/bash

set -e


echo "In generate_dot_env.sh"

echo "$GHV_ENV" > "${GITHUB_ACTION_PATH}/operations/deployment/ansible/ghv.env"
echo "$GHS_ENV" > "${GITHUB_ACTION_PATH}/operations/deployment/ansible/ghs.env"
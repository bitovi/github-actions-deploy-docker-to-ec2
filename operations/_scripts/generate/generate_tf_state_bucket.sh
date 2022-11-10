#!/bin/bash

set -e

echo "In generate_tf_state_bucket.sh"

if [ -z "${TF_STATE_BUCKET}" ]; then

  ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
  REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')
  export TF_STATE_BUCKET = "${ORG_NAME}-${REPO_NAME}-tf-state"
fi

echo "TF_STATE_BUCKET"
echo "$TF_STATE_BUCKET"

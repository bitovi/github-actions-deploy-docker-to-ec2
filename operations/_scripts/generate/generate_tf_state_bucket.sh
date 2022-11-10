#!/bin/bash

set -e

if [ -z "${TF_STATE_BUCKET}" ]; then

  ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
  REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')
  export TF_STATE_BUCKET="${ORG_NAME}-${REPO_NAME}-tf-state"
  echo "no bucket"
else
  echo "has bucket"
fi

echo "foo($TF_STATE_BUCKET)"
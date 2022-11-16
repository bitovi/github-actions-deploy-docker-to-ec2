#!/bin/bash

set -e

if [ -z "${TF_STATE_BUCKET}" ]; then

  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
  export TF_STATE_BUCKET="${GITHUB_IDENTIFIER}-tf-state"
fi

echo "$TF_STATE_BUCKET"

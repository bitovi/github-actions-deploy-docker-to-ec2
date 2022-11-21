#!/bin/bash

set -e

if [ -z "${SUB_DOMAIN}" ]; then

  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
  export SUB_DOMAIN="${GITHUB_IDENTIFIER}"
fi

echo "$SUB_DOMAIN"

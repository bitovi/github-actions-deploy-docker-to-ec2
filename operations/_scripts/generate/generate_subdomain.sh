#!/bin/bash

set -e

if [ -z "${SUB_DOMAIN}" ]; then
  if [ -n "${GITHUB_IDENTIFIER}" ]; then
    GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
  fi
  export SUB_DOMAIN="${GITHUB_IDENTIFIER}"
fi

echo "$SUB_DOMAIN"
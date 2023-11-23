#!/bin/bash

set -e

if [ -z "$AWS_RESOURCE_IDENTIFIER" ]; then
  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/shorten_identifier.sh ${GITHUB_IDENTIFIER} 30)"
else
  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/shorten_identifier.sh ${AWS_RESOURCE_IDENTIFIER} 30)"
fi
echo "$GITHUB_IDENTIFIER" | xargs

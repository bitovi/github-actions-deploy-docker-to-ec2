#!/bin/bash

set -ex

echo "DEBUGGING"
echo "in generate_identifier_supershort.sh"

GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

if [ -n "$GITHUB_HEAD_REF" ]; then
  GITHUB_BRANCH_NAME=${GITHUB_HEAD_REF}
else
  GITHUB_BRANCH_NAME=${GITHUB_REF_NAME}
fi

if [ -z "$AWS_RESOURCE_IDENTIFIER" ]; then
  echo "no AWS_RESOURCE_IDENTIFIER, generate"
  GITHUB_IDENTIFIER="${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}"
  echo "GITHUB_IDENTIFIER before"
  echo "$GITHUB_IDENTIFIER"
  GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/shorten_identifier.sh ${GITHUB_IDENTIFIER} 30)"
  echo "GITHUB_IDENTIFIER after"
  echo "$GITHUB_IDENTIFIER"
else
  GITHUB_IDENTIFIER="$AWS_RESOURCE_IDENTIFIER"
fi
echo "$GITHUB_IDENTIFIER" | xargs
#!/bin/bash

set -e

GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"

case $1 in 
  tf)
      # Generate TF_STATE_BUCKET ID if empty 
      if [ -z "${TF_STATE_BUCKET}" ]; then
        #  Add trailing id depending on name length - See AWS S3 bucket naming rules
        if [[ ${#GITHUB_IDENTIFIER} < 55 ]]; then
          TF_STATE_BUCKET="${GITHUB_IDENTIFIER}-tf-state"
        else
          TF_STATE_BUCKET="${GITHUB_IDENTIFIER}-tf"
        fi
      fi
      echo "$TF_STATE_BUCKET"

  ;;
  lb)
      # Generate LB_LOGS_BUCKET ID
      #  Add trailing id depending on name length - See AWS S3 bucket naming rules
      if [[ ${#GITHUB_IDENTIFIER} < 59 ]]; then
        LB_LOGS_BUCKET="${GITHUB_IDENTIFIER}-logs"
      else
        LB_LOGS_BUCKET="${GITHUB_IDENTIFIER}-lg"
      fi
      echo "$LB_LOGS_BUCKET"
  ;;
esac
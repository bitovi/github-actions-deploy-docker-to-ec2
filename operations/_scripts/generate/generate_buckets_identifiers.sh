#!/bin/bash

### S3 Buckets name must follow AWS rules. Info below.
### https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

set -e

GITHUB_IDENTIFIER="$(echo $($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh) | tr '[:upper:]' '[:lower:]')"

function checkBucket() {
  # check length of bucket name
  if [[ ${#1} -lt 3 || ${#1} -gt 63 ]]; then
    echo "Bucket name must be between 3 and 63 characters long."
    exit 1
  fi
  
  # check that bucket name consists only of lowercase letters, numbers, dots (.), and hyphens (-)
  if [[ ! $1 =~ ^[a-z0-9.-]+$ ]]; then
    echo "Bucket name can only consist of lowercase letters, numbers, dots (.), and hyphens (-)."
    exit 1
  fi
  
  # check that bucket name begins and ends with a letter or number
  if [[ ! $1 =~ ^[a-zA-Z0-9] ]]; then
    echo "Bucket name must begin with a letter or number."
    exit 1
  fi
  if [[ ! $1 =~ [a-zA-Z0-9]$ ]]; then
    echo "Bucket name must end with a letter or number."
    exit 1
  fi
  
  # check that bucket name does not contain two adjacent periods
  if [[ $1 =~ \.\. ]]; then
    echo "Bucket name cannot contain two adjacent periods."
    exit 1
  fi
  
  # check that bucket name is not formatted as an IP address
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Bucket name cannot be formatted as an IP address."
    exit 1
  fi
  
  # check that bucket name does not start with the prefix xn--
  if [[ $1 =~ ^xn-- ]]; then
    echo "Bucket name cannot start with the prefix xn--."
    exit 1
  fi
  
  # check that bucket name does not end with the suffix -s3alias
  if [[ $1 =~ -s3alias$ ]]; then
    echo "Bucket name cannot end with the suffix -s3alias."
    exit 1
  fi
}

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
      checkBucket $TF_STATE_BUCKET
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
      checkBucket $LB_LOGS_BUCKET
      echo "$LB_LOGS_BUCKET"
  ;;
esac
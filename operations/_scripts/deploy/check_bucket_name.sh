#!/bin/bash 

set -e 

### S3 Buckets name must follow AWS rules. Info below.
### https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html

function checkBucket() {
  # check length of bucket name
  if [[ ${#1} -lt 3 || ${#1} -gt 63 ]]; then
    echo "::error::Bucket name must be between 3 and 63 characters long."
    exit 1
  fi
  
  # check that bucket name consists only of lowercase letters, numbers, dots (.), and hyphens (-)
  if [[ ! $1 =~ ^[a-z0-9.-]+$ ]]; then
    echo "::error::Bucket name can only consist of lowercase letters, numbers, dots (.), and hyphens (-)."
    exit 1
  fi
  
  # check that bucket name begins and ends with a letter or number
  if [[ ! $1 =~ ^[a-zA-Z0-9] ]]; then
    echo "::error::Bucket name must begin with a letter or number."
    exit 1
  fi
  if [[ ! $1 =~ [a-zA-Z0-9]$ ]]; then
    echo "::error::Bucket name must end with a letter or number."
    exit 1
  fi
  
  # check that bucket name does not contain two adjacent periods
  if [[ $1 =~ \.\. ]]; then
    echo "::error::Bucket name cannot contain two adjacent periods."
    exit 1
  fi
  
  # check that bucket name is not formatted as an IP address
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "::error::Bucket name cannot be formatted as an IP address."
    exit 1
  fi
  
  # check that bucket name does not start with the prefix xn--
  if [[ $1 =~ ^xn-- ]]; then
    echo "::error::Bucket name cannot start with the prefix xn--."
    exit 1
  fi
  
  # check that bucket name does not end with the suffix -s3alias
  if [[ $1 =~ -s3alias$ ]]; then
    echo "::error::Bucket name cannot end with the suffix -s3alias."
    exit 1
  fi
}

checkBucket $1
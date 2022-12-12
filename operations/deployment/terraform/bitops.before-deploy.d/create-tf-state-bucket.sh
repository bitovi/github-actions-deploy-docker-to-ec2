#!/bin/bash

if [[ ${#TF_STATE_BUCKET} > 63 ]]; then
  echo "Bucket name exceeds name limit"
  exit 63
else
  echo "Creating TF_STATE_BUCKET: $TF_STATE_BUCKET"
  if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
    aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION || true
  else
    aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true
  fi

  if ! [[ -z $(aws s3api head-bucket --bucket $TF_STATE_BUCKET 2>&1) ]]; then
    echo "Bucket does not exist or permission is not there to use it."
    exit 63
  fi
fi

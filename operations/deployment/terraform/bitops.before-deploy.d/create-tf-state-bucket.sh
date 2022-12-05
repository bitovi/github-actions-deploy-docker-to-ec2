#!/bin/bash
echo "Creating TF_STATE_BUCKET: $TF_STATE_BUCKET"
if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
  aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION || true
else
  aws s3api create-bucket --bucket $TF_STATE_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION || true
fi

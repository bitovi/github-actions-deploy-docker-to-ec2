#!/bin/bash

if [[ $TF_STATE_BUCKET_DESTROY = true ]] ; then
  echo "Destroying S3 buket --> $TF_STATE_BUCKET"
  aws s3 rb s3://$TF_STATE_BUCKET --force
fi

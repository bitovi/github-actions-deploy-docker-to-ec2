#!/bin/bash

if ( $TERRAFORM_DESTROY ) ; then
  echo "Destroying S3 buket"
  aws s3 rb s3://$TF_STATE_BUCKET --force
fi

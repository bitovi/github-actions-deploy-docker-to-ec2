#!/bin/bash

if [[ $TERRAFORM_DESTROY = true ]] ; then
  echo "Destroying S3 buket"
  aws s3 rb s3://$TF_STATE_BUCKET --force
fi


ls -lah /opt
ls -lah /opt/bitops_deployment
find / -iname bo-out.env
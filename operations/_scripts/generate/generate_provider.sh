#!/bin/bash

set -e

# TODO: use templating
#    provide '.tf.tmpl' files in the 'operations/deployment' repo
#    and iterate over all of them to provide context with something like jinja
#    Example: https://github.com/mattrobenolt/jinja2-cli
#    jinja2 some_file.tmpl data.json --format=json

echo "In generate_provider.sh"

echo "
terraform {
  required_providers {
    aws = {
      source  = \"hashicorp/aws\"
      version = \"~> 3.0\"
    }

  }
  backend \"s3\" {
    region  = \"${AWS_DEFAULT_REGION}\"
    bucket  = \"${TF_STATE_BUCKET}\"
    key     = \"tf-state\"
    encrypt = true #AES-256encryption
  }
}
 
data \"aws_region\" \"current\" {}

provider \"aws\" {
  region = \"${AWS_DEFAULT_REGION}\"
  profile = \"default\"
  default_tags {
    tags = local.aws_tags
  }
}
" >> "${GITHUB_ACTION_PATH}/operations/deployment/terraform/provider.tf"
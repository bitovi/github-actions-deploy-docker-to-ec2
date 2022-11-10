#!/bin/bash

set -e


# TODO: use templating
#    provide '.tf.tmpl' files in the 'operations/deployment' repo
#    and iterate over all of them to provide context with something like jinja
#    Example: https://github.com/mattrobenolt/jinja2-cli
#    jinja2 some_file.tmpl data.json --format=json

echo "In generate_tf_vars.sh"


GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')


echo "
# the name of the operations repo environment directory
app_port = \"$APP_PORT\"

# the name of the operations repo environment directory
ops_repo_environment = \"deployment\"

# provide the name of the repo's org
app_org_name = \"${GITHUB_ORG_NAME}\"

# provide the name of the repo (should correspond to the app_repo_clone_url)
app_repo_name = \"${GITHUB_REPO_NAME}\"

# Path on the instance where the app will be cloned (do not include app_repo_name)
app_install_root = \"/home/ubuntu\"

# logs
lb_access_bucket_name = \"${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-lb-access-logs\"

" >> "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"

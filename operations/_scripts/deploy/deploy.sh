#!/bin/bash

#set -x

echo "::group::In Deploy"
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

# Generate buckets identifiers and check them agains AWS Rules 
export TF_STATE_BUCKET="$(/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_buckets_identifiers.sh tf | xargs)"
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/deploy/check_bucket_name.sh $TF_STATE_BUCKET
export LB_LOGS_BUCKET="$(/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_buckets_identifiers.sh lb | xargs)"
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/deploy/check_bucket_name.sh $LB_LOGS_BUCKET

# Generate subdomain
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_subdomain.sh

# Generate the provider.tf file
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_provider.sh

# Generate terraform variables
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_tf_vars.sh

# Generate dot_env
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_dot_env.sh

# Generate app repo
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_app_repo.sh

# Generate bitops config
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_bitops_config.sh

# Generate Ansible playbook
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_ansible_playbook.sh

TERRAFORM_COMMAND=""
TERRAFORM_DESTROY=""
if [ "$STACK_DESTROY" == "true" ]; then
  TERRAFORM_COMMAND="destroy"
  TERRAFORM_DESTROY="true"
  ANSIBLE_SKIP_DEPLOY="true"
fi
echo "::endgroup::"

if [[ $SKIP_BITOPS_RUN == "true" ]]; then
  exit 1
fi

echo "::group::BitOps Excecution"  
echo "Running BitOps for env: $BITOPS_ENVIRONMENT"
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e BITOPS_ENVIRONMENT="${BITOPS_ENVIRONMENT}" \
-e SKIP_DEPLOY_TERRAFORM="${SKIP_DEPLOY_TERRAFORM}" \
-e SKIP_DEPLOY_HELM="${SKIP_DEPLOY_HELM}" \
-e BITOPS_TERRAFORM_COMMAND="${TERRAFORM_COMMAND}" \
-e TERRAFORM_DESTROY="${TERRAFORM_DESTROY}" \
-e ANSIBLE_SKIP_DEPLOY="${ANSIBLE_SKIP_DEPLOY}" \
-e TF_STATE_BUCKET="${TF_STATE_BUCKET}" \
-e TF_STATE_BUCKET_DESTROY="${TF_STATE_BUCKET_DESTROY}" \
-e DEFAULT_FOLDER_NAME="_default" \
-e BITOPS_FAST_FAIL="${BITOPS_FAST_FAIL}" \
-v $(echo $GITHUB_ACTION_PATH)/operations:/opt/bitops_deployment \
bitovi/bitops:2.5.0
BITOPS_RESULT=$?
echo "::endgroup::"

exit $BITOPS_RESULT
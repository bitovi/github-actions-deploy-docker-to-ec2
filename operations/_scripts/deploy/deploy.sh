#!/bin/bash

set -x


echo "In deploy.sh"

GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')


echo 'DEBUGGING'
echo "GITHUB_REF"
echo "$GITHUB_REF"
echo "GITHUB_BASE_REF"
echo "$GITHUB_BASE_REF"
echo "GITHUB_HEAD_REF"
echo "$GITHUB_HEAD_REF"
echo "GITHUB_REF_NAME"
echo "$GITHUB_REF_NAME"
echo "GITHUB_REF - branch only"
echo "${GITHUB_REF#refs/heads/}"
exit 0

# Generate the tf state bucket
export TF_STATE_BUCKET="$(/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_tf_state_bucket.sh)"

# Generate the provider.tf file
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_provider.sh

# Generate terraform variables
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_tf_vars.sh

# Generate dot_env
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_dot_env.sh

# Generate app repo
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_app_repo.sh


echo "DEBUGGING - in deploy.sh"
echo "cat GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf"
cat $GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf
echo "cat GITHUB_ACTION_PATH/operations/deployment/terraform/terraform.tfvars"
cat $GITHUB_ACTION_PATH/operations/deployment/terraform/terraform.tfvars
echo "ls GITHUB_ACTION_PATH/operations/deployment/ansible/app/${GITHUB_REPO_NAME}"
ls "$GITHUB_ACTION_PATH/operations/deployment/ansible/app/${GITHUB_REPO_NAME}"

TERRAFORM_COMMAND=""
if [ "$STACK_DESTROY" == "true" ]; then
  TERRAFORM_COMMAND="destroy"
fi


echo "Running BitOps for env: $BITOPS_ENVIRONMENT"
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e BITOPS_ENVIRONMENT="${BITOPS_ENVIRONMENT}" \
-e SKIP_DEPLOY_TERRAFORM="${SKIP_DEPLOY_TERRAFORM}" \
-e SKIP_DEPLOY_HELM="${SKIP_DEPLOY_HELM}" \
-e TERRAFORM_COMMAND="${TERRAFORM_COMMAND}" \
-e TF_STATE_BUCKET="${TF_STATE_BUCKET}" \
-e DEFAULT_FOLDER_NAME="_default" \
-v $(echo $GITHUB_ACTION_PATH)/operations:/opt/bitops_deployment \
bitovi/bitops:2.1.0

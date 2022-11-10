#!/bin/bash

set -x


echo "In deploy.sh"




# Generate the tf state bucket
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_tf_state_bucket.sh

# Generate the provider.tf file
/bin/bash $GITHUB_ACTION_PATH/operations/_scripts/generate/generate_provider.sh

# TODO: modify terraform variables


echo "DEBUGGING - in deploy.sh"
echo "cat GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf"
cat $GITHUB_ACTION_PATH/operations/deployment/terraform/provider.tf
exit 0


echo "Running BitOps for env: $BITOPS_ENVIRONMENT"
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
-e AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}" \
-e BITOPS_ENVIRONMENT="${BITOPS_ENVIRONMENT}" \
-e SKIP_DEPLOY_TERRAFORM="${SKIP_DEPLOY_TERRAFORM}" \
-e SKIP_DEPLOY_HELM="${SKIP_DEPLOY_ANSIBLE}" \
-e TF_STATE_BUCKET="${TF_STATE_BUCKET}" \
-e DEFAULT_FOLDER_NAME="_default" \
-v $(echo $GITHUB_ACTION_PATH)/operations:/opt/bitops_deployment \
bitovi/bitops:2.1.0

#!/bin/bash

set -e

echo "In generate_tf_vars.sh"

GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

if [ -n "$GITHUB_HEAD_REF" ]; then
  GITHUB_BRANCH_NAME=${GITHUB_HEAD_REF}
else
  GITHUB_BRANCH_NAME=${GITHUB_REF_NAME}
fi

GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
GITHUB_IDENTIFIER=$(echo $GITHUB_IDENTIFIER | tr "_" "-")
echo "GITHUB_IDENTIFIER: [$GITHUB_IDENTIFIER]"

GITHUB_IDENTIFIER_SS="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier_supershort.sh)"
GITHUB_IDENTIFIER_SS=$(echo $GITHUB_IDENTIFIER_SS | tr "_" "-")
echo "GITHUB_IDENTIFIER SS: [$GITHUB_IDENTIFIER_SS]"


# -------------------------------------------------- #
domain_name=
if [ -z "$DOMAIN_NAME" ]; then
  domain_name="domain_name = \"${DOMAIN_NAME}\""
fi

sub_domain_name=
if [ -z "$SUB_DOMAIN" ]; then
  sub_domain_name="sub_domain = \"$SUB_DOMAIN\""
fi

if [ -z "${EC2_INSTANCE_PROFILE}" ]; then
  EC2_INSTANCE_PROFILE="${GITHUB_IDENTIFIER}"
fi

app_port=
if [[ -n "$APP_PORT" ]];then
  app_port="app_port = \"$APP_PORT\""
fi

no_cert=
if [[ -n "$NO_CERT" ]];then
  no_cert="no_cert = ${NO_CERT}"
fi

efs_zone_mapping=
if [[ -n "$EFS_ZONE_MAPPING" ]];then
  efs_zone_mapping="zone_mapping = ${EFS_ZONE_MAPPING}"
fi

mount_efs=
if [[ -n "$MOUNT_EFS" ]];then
  mount_efs="mount_efs = \"${MOUNT_EFS}\""
fi

create_efs=
if [[ -n "$CREATE_EFS" ]];then
  create_efs="create_efs = \"${CREATE_EFS}\""
fi


efs_prevent_destroy=
if [[ -n "$EFS_PREVENT_DESTROY" ]]; then
  efs_prevent_destroy="efs_prevent_destroy=${EFS_PREVENT_DESTROY}"
fi

additional_tags=
if [[ -n "$ADDITIONAL_TAGS" ]]; then
  additional_tags="additional_tags = ${ADDITIONAL_TAGS}"
fi

# -------------------------------------------------- #
create_subnet_a=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-east-2' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-2' ]]; then
  create_subnet_a=true
fi

create_subnet_b=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-east-2' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-2' ]]; then
  create_subnet_b=true
fi

create_subnet_c=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-east-2' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-2' ]]; then
  create_subnet_c=true
fi

create_subnet_d=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]] || [[ $AWS_DEFAULT_REGION == 'us-west-2' ]]; then
  create_subnet_d=true
fi

create_subnet_e=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]]; then
  create_subnet_e=true
fi

create_subnet_f=
if [[ $AWS_DEFAULT_REGION == 'us-east-1' ]]; then
  create_subnet_f=true
fi


# -------------------------------------------------- #

echo "
$app_port

lb_port = \"$LB_PORT\"

lb_healthcheck = \"$LB_HEALTHCHECK\"

# the name of the operations repo environment directory
ops_repo_environment = \"deployment\"

# provide the name of the repo's org
app_org_name = \"${GITHUB_ORG_NAME}\"

# provide the name of the repo
app_repo_name = \"${GITHUB_REPO_NAME}\"

app_branch_name = \"${GITHUB_BRANCH_NAME}\"

# Path on the instance where the app will be cloned (do not include app_repo_name)
app_install_root = \"/home/ubuntu\"

# logs
lb_access_bucket_name = \"${LB_LOGS_BUCKET}\"


security_group_name = \"${GITHUB_IDENTIFIER}\"

ec2_iam_instance_profile = \"${EC2_INSTANCE_PROFILE}\"

ec2_instance_type = \"${EC2_INSTANCE_TYPE}\"

aws_resource_identifier = \"${GITHUB_IDENTIFIER}\"

aws_resource_identifier_supershort = \"${GITHUB_IDENTIFIER_SS}\"

aws_secret_env = \"${AWS_SECRET_ENV}\"

aws_ami_id = \"${AWS_AMI_ID}\"

$sub_domain_name

$domain_name

root_domain = \"${ROOT_DOMAIN}\"

cert_arn = \"${CERT_ARN}\"

create_root_cert = \"${CREATE_ROOT_CERT}\"

create_sub_cert = \"${CREATE_SUB_CERT}\"

$no_cert

$mount_efs

$create_efs

$zone_mapping

$create_subnet_a

$efs_prevent_destroy

$additional_tags
#
" > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"

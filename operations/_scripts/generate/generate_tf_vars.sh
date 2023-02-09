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

ec2_instance_type=
if [[ -n "$EC2_INSTANCE_TYPE" ]];then
  ec2_instance_type="ec2_instance_type = \"${EC2_INSTANCE_TYPE}\""
fi

app_port=
if [[ -n "$APP_PORT" ]];then
  app_port="app_port = \"$APP_PORT\""
fi

no_cert=
if [[ -n "$NO_CERT" ]];then
  no_cert="no_cert = ${NO_CERT}"
fi

#----- EFS -----#
create_efs=
if [[ -n "$CREATE_EFS" ]];then
  create_efs="create_efs = \"${CREATE_EFS}\""
fi

create_ha_efs=
if [[ -n "$CREATE_HA_EFS" ]];then
  create_ha_efs="create_ha_efs = \"${CREATE_HA_EFS}\""
fi

create_efs_replica=
if [[ -n "$CREATE_EFS_REPLICA" ]];then
  create_efs_replica="create_efs_replica = \"${CREATE_EFS_REPLICA}\""
fi

enable_efs_backup_policy=
if [[ -n "$ENABLE_EFS_BACKUP_POLICY" ]];then
  enable_efs_backup_policy="enable_efs_backup_policy = \"${ENABLE_EFS_BACKUP_POLICY}\""
fi

efs_zone_mapping=
if [[ -n "$EFS_ZONE_MAPPING" ]];then
  efs_zone_mapping="zone_mapping = ${EFS_ZONE_MAPPING}"
fi

efs_transition_to_inactive=
if [[ -n "$EFS_TRANSITION_TO_INACTIVE" ]];then
  efs_transition_to_inactive="efs_transition_to_inactive = \"${EFS_TRANSITION_TO_INACTIVE}\""
fi

replication_configuration_destination=
if [[ -n "$EFS_REPLICA_DESTINATION" ]];then
  replication_configuration_destination="replication_configuration_destination = \"${EFS_REPLICA_DESTINATION}\""
fi

mount_efs_id=
if [[ -n "$MOUNT_EFS_ID" ]];then
  mount_efs_id="mount_efs_id = \"${MOUNT_EFS_ID}\""
fi

mount_efs_security_group_id=
if [[ -n "$MOUNT_EFS_SECURITY_GROUP_ID" ]];then
  mount_efs_security_group_id="mount_efs_security_group_id = \"${MOUNT_EFS_SECURITY_GROUP_ID}\""
fi

#------------------------------------#

additional_tags=
if [[ -n "$ADDITIONAL_TAGS" ]]; then
  additional_tags="additional_tags = ${ADDITIONAL_TAGS}"
fi

root_domain=
if [[ -n "$ROOT_DOMAIN" ]]; then
  root_domain="root_domain = \"${ROOT_DOMAIN}\""
fi

cert_arn=
if [[ -n "$CERT_ARN" ]]; then
  cert_arn="cert_arn = \"${CERT_ARN}\""
fi

create_root_cert=
if [[ -n "$CREATE_ROOT_CERT" ]]; then
  create_root_cert="create_root_cert = \"${CREATE_ROOT_CERT}\""
fi

create_sub_cert=
if [[ -n "$CREATE_SUB_CERT" ]]; then
  create_sub_cert="create_sub_cert = \"${CREATE_SUB_CERT}\""
fi

aws_resource_identifier=
if [[ -n "$GITHUB_IDENTIFIER" ]]; then
  aws_resource_identifier="aws_resource_identifier = \"${GITHUB_IDENTIFIER}\""
fi

aws_resource_identifier_supershort=
if [[ -n "$GITHUB_IDENTIFIER_SS" ]]; then
  aws_resource_identifier_supershort="aws_resource_identifier_supershort = \"${GITHUB_IDENTIFIER_SS}\""
fi

aws_secret_env=
if [[ -n "$AWS_SECRET_ENV" ]]; then
  aws_secret_env="aws_secret_env = \"${AWS_SECRET_ENV}\""
fi

aws_ami_id=
if [[ -n "$AWS_AMI_ID" ]]; then
  aws_ami_id="aws_ami_id = \"${AWS_AMI_ID}\""
fi

lb_port=
if [[ -n "$LB_PORT" ]]; then
  lb_port="lb_port = \"$LB_PORT\""
fi

lb_healthcheck=
if [[ -n "$LB_HEALTHCHECK" ]]; then
  lb_healthcheck="lb_healthcheck = \"$LB_HEALTHCHECK\""
fi

lb_access_bucket_name=
if [[ -n "$LB_LOGS_BUCKET" ]]; then
  lb_access_bucket_name="lb_access_bucket_name = \"${LB_LOGS_BUCKET}\""
fi

# security_group_name=
# if [[ -n "$GITHUB_IDENTIFIER" ]]; then
#   security_group_name="security_group_name = \"${GITHUB_IDENTIFIER}\""
# fi

# ec2_iam_instance_profile=
# if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
#   ec2_iam_instance_profile="ec2_iam_instance_profile = \"${EC2_INSTANCE_PROFILE}\""
# fi

ops_repo_environment=
if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
  ops_repo_environment="ops_repo_environment = \"deployment\""
fi

app_org_name=
if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
  app_org_name="app_org_name = \"${GITHUB_ORG_NAME}\""
fi

app_repo_name=
if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
  app_repo_name="app_repo_name = \"${GITHUB_REPO_NAME}\""
fi

app_branch_name=
if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
  app_branch_name="app_branch_name = \"${GITHUB_BRANCH_NAME}\""
fi

app_install_root=
if [[ -n "$EC2_INSTANCE_PROFILE" ]]; then
  app_install_root="app_install_root = \"/home/ubuntu\""
fi

# -------------------------------------------------- #

echo "
#-- Application --#
$app_port
$ops_repo_environment
$app_org_name
$app_repo_name
$app_branch_name
$app_install_root

#-- Load Balancer --#
$lb_port
$lb_healthcheck

#-- Logging --#
$lb_access_bucket_name

#-- Security Groups --#


#-- EC2 --#
$ec2_instance_type

#-- AWS --#
$aws_resource_identifier
$aws_resource_identifier_supershort
$aws_secret_env
$aws_ami_id

#-- Certificates --#
$sub_domain_name
$domain_name
$root_domain
$cert_arn
$create_root_cert
$create_sub_cert
$no_cert

#-- EFS --#
$create_efs
$create_ha_efs
$create_efs_replica
$enable_efs_backup_policy
$efs_zone_mapping
$efs_transition_to_inactive
$replication_configuration_destination
$mount_efs_id
$mount_efs_security_group_id

#-- Tags --#
$additional_tags

" > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"

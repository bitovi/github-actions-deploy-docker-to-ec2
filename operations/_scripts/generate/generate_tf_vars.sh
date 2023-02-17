#!/bin/bash

set -e

echo "In generate_tf_vars.sh"

# convert 'a,b,c'
# to '["a","b","c"]'
comma_str_to_tf_array () {
  local IFS=','
  local str=$1

  local out=""
  local first_item_flag="1"
  for item in $str; do
    if [ -z $first_item_flag ]; then
      out="${out},"
    fi
    first_item_flag=""

    item="$(echo $item | xargs)"
    out="${out}\"${item}\""
  done
  echo "[${out}]"
}

GITHUB_ORG_NAME=$(echo $GITHUB_REPOSITORY | sed 's/\/.*//')
GITHUB_REPO_NAME=$(echo $GITHUB_REPOSITORY | sed 's/^.*\///')

if [ -n "$GITHUB_HEAD_REF" ]; then
  GITHUB_BRANCH_NAME=${GITHUB_HEAD_REF}
else
  GITHUB_BRANCH_NAME=${GITHUB_REF_NAME}
fi

# Translating  '/' '-' and '_' '-'  in the same line

GITHUB_IDENTIFIER="$(echo $($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh) | tr '/' '-' | tr '_' '-' )"
echo "GITHUB_IDENTIFIER: [$GITHUB_IDENTIFIER]"

GITHUB_IDENTIFIER_SS="$(echo $($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier_supershort.sh) | tr '/' '-' | tr '_' '-' )"
echo "GITHUB_IDENTIFIER SS: [$GITHUB_IDENTIFIER_SS]"


# -------------------------------------------------- #
domain_name=
if [ -n "$DOMAIN_NAME" ]; then
  domain_name="domain_name = \"${DOMAIN_NAME}\""
fi

sub_domain_name=
if [ -n "$SUB_DOMAIN" ]; then
  sub_domain_name="sub_domain_name = \"$SUB_DOMAIN_NAME\""
else
  sub_domain_name="sub_domain_name = \"$GITHUB_IDENTIFIER\""
fi

ec2_iam_instance_profile=
if [ -n "${EC2_INSTANCE_PROFILE}" ]; then
  ec2_iam_instance_profile="ec2_iam_instance_profile =\"${EC2_INSTANCE_PROFILE}\""
else
  ec2_iam_instance_profile="ec2_iam_instance_profile =\"${GITHUB_IDENTIFIER}\""
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
aws_create_efs=
if [[ -n "$AWS_CREATE_EFS" ]];then
  aws_create_efs="aws_create_efs = \"${AWS_CREATE_EFS}\""
fi

aws_create_ha_efs=
if [[ -n "$AWS_CREATE_HA_EFS" ]];then
  aws_create_ha_efs="aws_create_ha_efs = \"${AWS_CREATE_HA_EFS}\""
fi

aws_create_efs_replica=
if [[ -n "$AWS_CREATE_EFS_REPLICA" ]];then
  aws_create_efs_replica="aws_create_efs_replica = \"${AWS_CREATE_EFS_REPLICA}\""
fi

aws_enable_efs_backup_policy=
if [[ -n "$AWS_ENABLE_EFS_BACKUP_POLICY" ]];then
  aws_enable_efs_backup_policy="aws_enable_efs_backup_policy = \"${AWS_ENABLE_EFS_BACKUP_POLICY}\""
fi

aws_efs_zone_mapping=
if [[ -n "$AWS_EFS_ZONE_MAPPING" ]];then
  aws_efs_zone_mapping="aws_efs_zone_mapping = ${AWS_EFS_ZONE_MAPPING}"
fi

aws_efs_transition_to_inactive=
if [[ -n "$AWS_EFS_TRANSITION_TO_INACTIVE" ]];then
  aws_efs_transition_to_inactive="aws_efs_transition_to_inactive = \"${AWS_EFS_TRANSITION_TO_INACTIVE}\""
fi

aws_replication_configuration_destination=
if [[ -n "$AWS_EFS_REPLICA_DESTINATION" ]];then
  aws_replication_configuration_destination="aws_replication_configuration_destination = \"${AWS_EFS_REPLICA_DESTINATION}\""
fi

aws_mount_efs_id=
if [[ -n "$AWS_MOUNT_EFS_ID" ]];then
  aws_mount_efs_id="aws_mount_efs_id = \"${AWS_MOUNT_EFS_ID}\""
fi

aws_mount_efs_security_group_id=
if [[ -n "$AWS_MOUNT_EFS_SECURITY_GROUP_ID" ]];then
  aws_mount_efs_security_group_id="aws_mount_efs_security_group_id = \"${AWS_MOUNT_EFS_SECURITY_GROUP_ID}\""
fi

#------------------------------------#

additional_tags=
if [[ -n "$ADDITIONAL_TAGS" ]]; then
  additional_tags="additional_tags = ${ADDITIONAL_TAGS}"
fi

application_mount_target=
if [[ -n "$APPLICATION_MOUNT_TARGET" ]]; then
  application_mount_target="application_mount_target = \"${APPLICATION_MOUNT_TARGET}\""
fi

efs_mount_target=
if [[ -n "$EFS_MOUNT_TARGET" ]]; then
  efs_mount_target="efs_mount_target = \"${EFS_MOUNT_TARGET}\""
fi

data_mount_target=
if [[ -n "$DATA_MOUNT_TARGET" ]]; then
  data_mount_target="data_mount_target = \"${DATA_MOUNT_TARGET}\""
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

# Should this be moved to a defaults?
ops_repo_environment="ops_repo_environment = \"deployment\""
security_group_name="security_group_name = \"${GITHUB_IDENTIFIER}\""
app_install_root="app_install_root = \"/home/ubuntu\""

app_org_name=
if [[ -n "$GITHUB_ORG_NAME" ]]; then
  app_org_name="app_org_name = \"${GITHUB_ORG_NAME}\""
fi

app_repo_name=
if [[ -n "$GITHUB_REPO_NAME" ]]; then
  app_repo_name="app_repo_name = \"${GITHUB_REPO_NAME}\""
fi

app_branch_name=
if [[ -n "$GITHUB_BRANCH_NAME" ]]; then
  app_branch_name="app_branch_name = \"${GITHUB_BRANCH_NAME}\""
fi

create_keypair_sm_entry=
if [[ -n "$CREATE_KEYPAIR_SM_ENTRY" ]]; then
  create_keypair_sm_entry="create_keypair_sm_entry = \"${CREATE_KEYPAIR_SM_ENTRY}\""
fi

# RDS

postgres_subnets=
if [ -n "${POSTGRES_SUBNETS}" ]; then
  POSTGRES_SUBNETS_TF="postgres_subnets = "
  POSTGRES_SUBNETS_TF="${POSTGRES_SUBNETS_TF}$(comma_str_to_tf_array $POSTGRES_SUBNETS)"
else
  POSTGRES_SUBNETS_TF=
fi

security_group_name_pg = \"${GITHUB_IDENTIFIER}-pg\"
enable_postgres = \"${ENABLE_POSTGRES}\"
postgres_engine = \"${POSTGRES_ENGINE}\"
postgres_engine_version = \"${POSTGRES_ENGINE_VERSION}\"
postgres_instance_class = \"${POSTGRES_INSTANCE_CLASS}\"
postgres_database_name = \"${POSTGRES_DATABASE_NAME}\"
postgres_database_port = \"${POSTGRES_DATABASE_PORT}\"
${POSTGRES_SUBNETS_TF}

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
$security_group_name

#-- EC2 --#
$ec2_instance_type
$ec2_instance_profile
$ec2_iam_instance_profile

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
$aws_create_efs
$aws_create_ha_efs
$aws_create_efs_replica
$aws_enable_efs_backup_policy
$aws_efs_zone_mapping
$aws_efs_transition_to_inactive
$aws_replication_configuration_destination
$aws_mount_efs_id
$aws_mount_efs_security_group_id

#-- Security Manager --#
$create_keypair_sm_entry

#-- Tags --#
$additional_tags

##-- ANSIBLE --##
$application_mount_target
$efs_mount_target
$data_mount_target

" > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"
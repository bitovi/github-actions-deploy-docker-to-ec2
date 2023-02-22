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


GITHUB_IDENTIFIER="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier.sh)"
echo "GITHUB_IDENTIFIER: [$GITHUB_IDENTIFIER]"

GITHUB_IDENTIFIER_SS="$($GITHUB_ACTION_PATH/operations/_scripts/generate/generate_identifier_supershort.sh)"
echo "GITHUB_IDENTIFIER SS: [$GITHUB_IDENTIFIER_SS]"


# -------------------------------------------------- #
# Generator # 
generate () {
  $1=
  if [[ -n "$2" ]];then
    $1="$1 = \"\${$2}\""
  fi
}

# Fixed values

ops_repo_environment="ops_repo_environment = \"deployment\""
app_org_name="app_org_name = \"${GITHUB_ORG_NAME}\""
app_repo_name="app_repo_name = \"${GITHUB_REPO_NAME}\""
app_branch_name="app_branch_name = \"${GITHUB_BRANCH_NAME}\""
app_install_root="app_install_root = \"/home/ubuntu\""
security_group_name="security_group_name = \"${GITHUB_IDENTIFIER}\""
aws_resource_identifier="aws_resource_identifier = \"${GITHUB_IDENTIFIER}\""
aws_resource_identifier_supershort="aws_resource_identifier_supershort = \"${GITHUB_IDENTIFIER_SS}\""
aws_security_group_name_pg="aws_security_group_name_pg = \"${GITHUB_IDENTIFIER}-pg\""

# Special cases

ec2_iam_instance_profile=
if [ -n "${EC2_INSTANCE_PROFILE}" ]; then
  ec2_iam_instance_profile="ec2_iam_instance_profile =\"${EC2_INSTANCE_PROFILE}\""
else
  ec2_iam_instance_profile="ec2_iam_instance_profile =\"${GITHUB_IDENTIFIER}\""
fi

sub_domain_name=
if [ -n "$SUB_DOMAIN" ]; then
  sub_domain_name="sub_domain_name = \"$SUB_DOMAIN\""
else
  sub_domain_name="sub_domain_name = \"$GITHUB_IDENTIFIER\""
fi

aws_postgres_subnets=
if [ -n "${AWS_POSTGRES_SUBNETS}" ]; then
  aws_postgres_subnets="aws_postgres_subnets = \"$(comma_str_to_tf_array $AWS_POSTGRES_SUBNETS)\""
fi
echo "AWS Postgres subnets: $aws_postgres_subnets"


#-- Application --#
generate app_port APP_PORT
# generate ops_repo_environment OPS_REPO_ENVIRONMENT - Fixed
# generate app_org_name APP_ORG_NAME - Fixed
# generate app_repo_name APP_REPO_NAME - Fixed
# generate app_branch_name APP_BRANCH_NAME - Fixed
# generate app_install_root APP_INSTALL_ROOT - Fixed
#-- Load Balancer --#
generate lb_port LB_PORT
generate lb_healthcheck LB_HEALTHCHECK
#-- Logging --#
generate lb_access_bucket_name LB_LOGS_BUCKET
#-- Security Groups --#
generate security_group_name SECURITY_GROUP_NAME
#-- EC2 --#
generate ec2_instance_type EC2_INSTANCE_TYPE
#generate ec2_iam_instance_profile EC2_INSTANCE_PROFILE - Special case
#-- AWS --#
#generate aws_resource_identifier AWS_RESOURCE_IDENTIFIER - Fixed
#generate aws_resource_identifier_supershort AWS_RESOURCE_IDENTIFIER_SUPERSHORT - Fixed
generate aws_secret_env AWS_SECRET_ENV
generate aws_ami_id AWS_AMI_ID
#-- Certificates --#
#generate sub_domain_name SUB_DOMAIN_NAME  - Special case
generate domain_name DOMAIN_NAME
generate root_domain ROOT_DOMAIN
generate cert_arn CERT_ARN
generate create_root_cert CREATE_ROOT_CERT
generate create_sub_cert CREATE_SUB_CERT
generate no_cert NO_CERT
#-- EFS --#
generate aws_create_efs AWS_CREATE_EFS
generate aws_create_ha_efs AWS_CREATE_HA_EFS
generate aws_create_efs_replica AWS_CREATE_EFS_REPLICA
generate aws_enable_efs_backup_policy AWS_ENABLE_EFS_BACKUP_POLICY
generate aws_efs_zone_mapping AWS_EFS_ZONE_MAPPING
generate aws_efs_transition_to_inactive AWS_EFS_TRANSITION_TO_INACTIVE
generate aws_replication_configuration_destination AWS_EFS_REPLICA_DESTINATION
generate aws_mount_efs_id AWS_MOUNT_EFS_ID
generate aws_mount_efs_security_group_id AWS_MOUNT_EFS_SECURITY_GROUP_ID
#-- RDS --#
# generate aws_security_group_name_pg AWS_SECURITY_GROUP_NAME_PG - Fixed
generate aws_enable_postgres AWS_ENABLE_POSTGRES
generate aws_postgres_engine AWS_POSTGRES_ENGINE
generate aws_postgres_engine_version AWS_POSTGRES_ENGINE_VERSION
generate aws_postgres_instance_class AWS_POSTGRES_INSTANCE_CLASS
generate aws_postgres_database_name AWS_POSTGRES_DATABASE_NAME
generate aws_postgres_database_port AWS_POSTGRES_DATABASE_PORT
# generate aws_postgres_subnets AWS_POSTGRES_SUBNETS - Special case
#-- Security Manager --#
generate create_keypair_sm_entry CREATE_KEYPAIR_SM_ENTRY
#-- Tags --#
generate additional_tags ADDITIONAL_TAGS
#-- ANSIBLE --##
generate application_mount_target APPLICATION_MOUNT_TARGET
generate efs_mount_target EFS_MOUNT_TARGET
generate data_mount_target DATA_MOUNT_TARGET


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

#-- RDS --#
$aws_security_group_name_pg
$aws_enable_postgres
$aws_postgres_engine
$aws_postgres_engine_version
$aws_postgres_instance_class
$aws_postgres_database_name
$aws_postgres_database_port
$aws_postgres_subnets

#-- Security Manager --#
$create_keypair_sm_entry

#-- Tags --#
$additional_tags

##-- ANSIBLE --##
$application_mount_target
$efs_mount_target
$data_mount_target

" > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"
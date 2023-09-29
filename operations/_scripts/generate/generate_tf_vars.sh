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
# Function to generate the variable content based on the fact that it could be empty. 
# This way, we only pass terraform variables that are defined, hence not overwriting terraform defaults. 

function alpha_only() {
    echo "$1" | tr -cd '[:alpha:]' | tr '[:upper:]' '[:lower:]'
}

function generate_var () {
  if [[ -n "$2" ]];then
    if [[ $(alpha_only "$2") == "true" ]] || [[ $(alpha_only "$2") == "false" ]]; then
      echo "$1 = $(alpha_only $2)"
    else
      echo "$1 = \"$2\""
    fi
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

#-- Application --#
app_port=$(generate_var app_port $APP_PORT)
# ops_repo_environment=$(generate_var ops_repo_environment OPS_REPO_ENVIRONMENT - Fixed
# app_org_name=$(generate_var app_org_name APP_ORG_NAME - Fixed
# app_repo_name=$(generate_var app_repo_name APP_REPO_NAME - Fixed
# app_branch_name=$(generate_var app_branch_name APP_BRANCH_NAME - Fixed
# app_install_root=$(generate_var app_install_root APP_INSTALL_ROOT - Fixed
#-- Load Balancer --#
lb_port=$(generate_var lb_port $LB_PORT)
lb_healthcheck=$(generate_var lb_healthcheck $LB_HEALTHCHECK)
#-- Logging --#
lb_access_bucket_name=$(generate_var lb_access_bucket_name $LB_LOGS_BUCKET)
#-- Security Groups --#
#security_group_name=$(generate_var security_group_name $SECURITY_GROUP_NAME) - Fixed
#-- EC2 --#
ec2_instance_type=$(generate_var ec2_instance_type $EC2_INSTANCE_TYPE)
# ec2_iam_instance_profile=$(generate_var ec2_iam_instance_profile EC2_INSTANCE_PROFILE - Special case
#-- AWS --#
# aws_resource_identifier=$(generate_var aws_resource_identifier AWS_RESOURCE_IDENTIFIER - Fixed
# aws_resource_identifier_supershort=$(generate_var aws_resource_identifier_supershort AWS_RESOURCE_IDENTIFIER_SUPERSHORT - Fixed
aws_secret_env=$(generate_var aws_secret_env $AWS_SECRET_ENV)
aws_ami_id=$(generate_var aws_ami_id $AWS_AMI_ID)
#-- Certificates --#
# sub_domain_name=$(generate_var sub_domain_name $SUB_DOMAIN_NAME)  - Special case
domain_name=$(generate_var domain_name $DOMAIN_NAME)
root_domain=$(generate_var root_domain $ROOT_DOMAIN)
cert_arn=$(generate_var cert_arn $CERT_ARN)
create_root_cert=$(generate_var create_root_cert $CREATE_ROOT_CERT)
create_sub_cert=$(generate_var create_sub_cert $CREATE_SUB_CERT)
no_cert=$(generate_var no_cert $NO_CERT)
#-- EFS --#
if [[ $(alpha_only "$AWS_EFS_CREATE") == true ]] || [[ $(alpha_only "$AWS_EFS_CREATE_HA") == true ]] || [[ $AWS_MOUNT_EFS_ID != "" ]]; then
  aws_create_efs=$(generate_var aws_create_efs $AWS_CREATE_EFS)
  aws_create_ha_efs=$(generate_var aws_create_ha_efs $AWS_CREATE_HA_EFS)
  aws_create_efs_replica=$(generate_var aws_create_efs_replica $AWS_CREATE_EFS_REPLICA)
  aws_enable_efs_backup_policy=$(generate_var aws_enable_efs_backup_policy $AWS_ENABLE_EFS_BACKUP_POLICY)
  aws_efs_zone_mapping=$(generate_var aws_efs_zone_mapping $AWS_EFS_ZONE_MAPPING)
  aws_efs_transition_to_inactive=$(generate_var aws_efs_transition_to_inactive $AWS_EFS_TRANSITION_TO_INACTIVE)
  aws_replication_configuration_destination=$(generate_var aws_replication_configuration_destination $AWS_EFS_REPLICA_DESTINATION)
  aws_mount_efs_id=$(generate_var aws_mount_efs_id $AWS_MOUNT_EFS_ID)
  aws_mount_efs_security_group_id=$(generate_var aws_mount_efs_security_group_id $AWS_MOUNT_EFS_SECURITY_GROUP_ID)
fi
#-- RDS --#
if [[ $(alpha_only "$AWS_POSTGRES_ENABLE") == true ]]; then
  # aws_security_group_name_pg=$(generate_var aws_security_group_name_pg $AWS_SECURITY_GROUP_NAME_PG) - Fixed
  aws_enable_postgres=$(generate_var aws_enable_postgres $AWS_ENABLE_POSTGRES)
  aws_postgres_engine=$(generate_var aws_postgres_engine $AWS_POSTGRES_ENGINE)
  aws_postgres_engine_version=$(generate_var aws_postgres_engine_version $AWS_POSTGRES_ENGINE_VERSION)
  aws_postgres_database_group_family=$(generate_var aws_postgres_database_group_family $AWS_POSTGRES_DATABASE_GROUP_FAMILY)
  aws_postgres_instance_class=$(generate_var aws_postgres_instance_class $AWS_POSTGRES_INSTANCE_CLASS)
  aws_postgres_database_name=$(generate_var aws_postgres_database_name $AWS_POSTGRES_DATABASE_NAME)
  aws_postgres_database_port=$(generate_var aws_postgres_database_port $AWS_POSTGRES_DATABASE_PORT)
  aws_postgres_database_protection=$(generate_var aws_postgres_database_protection $AWS_POSTGRES_DATABASE_PROTECTION)
  aws_postgres_database_final_snapshot=$(generate_var aws_postgres_database_final_snapshot $AWS_POSTGRES_DATABASE_FINAL_SNAPSHOT)
fi
# aws_postgres_subnets=$(generate_var aws_postgres_subnets $AWS_POSTGRES_SUBNETS) - Special case
#-- Security Manager --#
create_keypair_sm_entry=$(generate_var create_keypair_sm_entry $CREATE_KEYPAIR_SM_ENTRY)
#-- Tags --#
additional_tags=$(generate_var additional_tags $ADDITIONAL_TAGS)
#-- ANSIBLE --##
application_mount_target=$(generate_var application_mount_target $APPLICATION_MOUNT_TARGET)
efs_mount_target=$(generate_var efs_mount_target $EFS_MOUNT_TARGET)
data_mount_target=$(generate_var data_mount_target $DATA_MOUNT_TARGET)
ec2_volume_size=$(generate_var ec2_volume_size $EC2_VOLUME_SIZE)
docker_remove_orphans=$(generate_var docker_remove_orphans $DOCKER_REMOVE_ORPHANS)
ansible_start_docker_timeout=$(generate_var ansible_start_docker_timeout $ANSIBLE_START_DOCKER_TIMEOUT)


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
$ec2_volume_size

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
$aws_postgres_database_group_family
$aws_postgres_instance_class
$aws_postgres_database_name
$aws_postgres_database_port
$aws_postgres_subnets
$aws_postgres_database_protection
$aws_postgres_database_final_snapshot

#-- Security Manager --#
$create_keypair_sm_entry

#-- Tags --#
$additional_tags

##-- ANSIBLE --##
$ansible_start_docker_timeout
$application_mount_target
$efs_mount_target
$data_mount_target
$docker_remove_orphans

" > "${GITHUB_ACTION_PATH}/operations/deployment/terraform/terraform.tfvars"
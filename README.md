# Docker to AWS VM

GitHub action to deploy any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an AWS VM (EC2) using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker-compose up`.

## Getting Started Intro Video
[![Getting Started - Youtube](https://img.youtube.com/vi/oya5LuHUCXc/0.jpg)](https://www.youtube.com/watch?v=oya5LuHUCXc)


## Need help or have questions?
This project is supported by [Bitovi, a DevOps Consultancy](https://www.bitovi.com/devops-consulting) and a proud supporter of Open Source software.

You can **get help or ask questions** on our [Discord channel](https://discord.gg/J7ejFsZnJ4)! Come hang out with us!

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/devops-consulting).

# CHANGELOG ---> WHAT'S NEW IN V1 - What changed? 

A lot! The whole code supporting this action migrated into a bigger repo, with more modules and functions. We concentrated our work there, hence any improvement done there benefits all of our actions.

Actions you said? Yes… go check our list of actions in the GitHub marketplace. https://github.com/marketplace?category=&type=actions&verification=&query=bitovi

New stuff! Will highlight the main new features, self-explanatory variables after. 

Reodered README and action.yaml files. 

## Introducing: 

### Get the code! (Using bitops_code_only and bitops_code_store)
This allow the code to be generated (not executed) and stored as an artifact as a result in your action, allowing you to download and check anything. Keep in mind this code runs in a Bitops container. (More [here](http://bitops.sh))

### Code welcome! 
Add your own Terraform and Ansible oode (using gh_deployment_* variables). - We open the possibility to add some Terraform and Ansible code in. Useful only for super-advanced users. 

### TF_STATE handling improvements!
tf_state filename handling (added tf_state_file_name and tf_state_file_name_append) This allows you to handle the tf_state filename, so if you want to store all of your states in one bucket, you can handle that here. 

### Cloudwatch for docker - Get your docker logs into AWS Cloudwatch!
No more need to go into the instance. You'll see 4 variables for this in the docker section.

### VPC Handling - Use default, create one or reuse an existing one, up to you!
Whole section below!

### ELB, EC2 and APP Ports - Need more than one? worry not. 
Add as many as you want, separating them with a coma. For the ELB, will be mapping one to one (aws_elb_listen_port <-> aws_elb_app_port) based on the minimum length of those.

### AWS_EFS received a revamp
Some variable names have changed (Detailed below)

### DATABASES! 
Now we allow RDS and Aurora DB’s to be created, and with a proxy too! The whole section changed.

### TAG EVERYTHING!
You'll find that after each main section there's a variable allowing you to add tags to those resources. Anything there will be ADDED to the default tags!

## Small details added, but maybe not that small.
- lb_create - Add toggle to allow disabling the ELB
- ansible_skip - Skips ansible execution after terraform finishes.
- ansible_ssh_to_private_ip - If using self hosted runner, will connect to the private IP of the EC2 instance.
- ec2_ami_update - Update the ami to the latest image if a new one exists. Will destroy and recreate the instance if so. (And the data with it)
- ec2_root_preserve - Keeps the root volume after deletion.
- ec2_instance_public_ip - In some cases, you don’t need the instance to have a public IP. 
- ec2_port_list - Ports to be opened just in the EC2 SG. (Port 22 is enabled as default) - Traffic from the ELB SG to the EC2 SG is automatically allowed.
- ec2_user_data_file - Allows adding a shell script to be executed when instance spins up.
- ec2_user_data_replace_on_change - That. If the user_data file changes, will stop and start the instance. (As it runs after start)

## Variable renaming happened. Sorry. 
| OLD | NEW |
|----------------------|----------------------|
| additional_tags | aws_additional_tags |
| targets | tf_targets |
| aws_ami_id | ec2_ami_id |
| aws_create_efs | aws_efs_create |
| aws_create_ha_efs | aws_efs_create_ha |
| aws_create_efs_replica | aws_efs_create_replica |
| aws_enable_efs_backup_policy | aws_efs_enable_backup_policy |
| efs_mount_target | aws_efs_mount_target |
| data_mount_target | docker_efs_mount_target |
| aws_replication_configuration_destination | aws_efs_replication_destination |
| aws_mount_efs_id | aws_efs_fs_id |
| no_cert | enable_cert |
<hr/>
<br/>

## Gone variables
- aws_efs_zone_mapping
- aws_mount_efs_security_group_id

## BREAKING CHANGES!!!
1. AWS RDS was renamed to Aurora, as we support both Postgres or MySQL engines.
2. EFS variable names changed completely for standarization purposes. 

## NON-BREAKING CHANGES
- ELB Healtcheck: Instead of `HTTP:app_port` now is static to `TCP:22`.
- EC2 Instance will only have the port 22 open. Any port defined in `app_port` and `lb_port` will apply to the ELB. See `ec2_port_list` to open instance ports. 

## Requirements

1. Files for Docker
2. An AWS account

### 1. Files for Docker
Your app needs a `Dockerfile` and a `docker-compose.yaml` file.

> For more details on setting up Docker and Docker Compose, check out Bitovi's Academy Course: [Learn Docker](https://www.bitovi.com/academy/learn-docker.html)
>

### 2. An AWS account
You'll need [Access Keys](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html) from an [AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

## Environment variables

For envirnoment variables in your app, you can provide:
 - `repo_env` - A file in your repo that contains env vars
 - `ghv_env` - An entry in [Github actions variables](https://docs.github.com/en/actions/learn-github-actions/variables)
 - `dot_env` - An entry in [Github secrets](https://docs.github.com/es/actions/security-guides/encrypted-secrets)
 - `aws_secret_env` - The path to a JSON format secret in AWS
 
Then hook it up in your `docker-compose.yaml` file like:

```
version: '3.9'
services:
  app:
    env_file: .env
```

These environment variables are merged to the .env file quoted in the following order:
 - Terraform passed env vars ( This is not optional nor customizable )
 - Repository checked-in env vars - repo_env file as default. (KEY=VALUE style)
 - Github Secret - Create a secret named DOT_ENV - (KEY=VALUE style)
 - AWS Secret - JSON style like '{"key":"value"}'

## Example usage

Create `.github/workflow/deploy.yaml` with the following to build on push.

### Basic example
```yaml
name: Basic deploy
on:
  push:
    branches: [ main ]

jobs:
  EC2-Deploy:
    runs-on: ubuntu-latest
    steps:
      - id: deploy
        uses: bitovi/github-actions-deploy-docker-to-ec2@v1.0.0
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws_default_region: us-east-1
          dot_env: ${{ secrets.DOT_ENV }}
```

### Advanced example

```yaml
name: Advanced deploy
on:
  push:
    branches: [ main ]

permissions:
  contents: read

jobs:
  EC2-Deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ github.ref_name }}
      url: ${{ steps.deploy.outputs.vm_url }}
    steps:
    - id: deploy
      name: Deploy
      uses: bitovi/github-actions-deploy-docker-to-ec2@v1.0.0
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws_session_token: ${{ secrets.AWS_SESSION_TOKEN }}
        aws_default_region: us-east-1
        domain_name: bitovi.com
        sub_domain: app
        tf_state_bucket: my-terraform-state-bucket
        dot_env: ${{ secrets.DOT_ENV }}
        ghv_env: ${{ vars.VARS }}
        app_port: 3000
        additional_tags: '{\"key\":\"value\",\"key2\":\"value2\"}'

```

## Customizing

### Inputs
1. [Action Defaults](#action-defaults-inputs)
1. [AWS Inputs](#aws-inputs)
1. [Stack management](#stack-management)
1. [Secrets and Environment Variables](#secrets-and-environment-variables-inputs)
1. [EC2](#ec2-inputs)
1. [Application](#application-inputs)
1. [Load Balancer](#load-balancer-inputs)
1. [VPC](#vpc-inputs)
1. [Certificates](#certificate-inputs)
1. [EFS](#efs-inputs)
1. [RDS Inputs](#rds-inputs)
1. [Aurora Inputs](#aurora-inputs)
1. [GitHub Deployment repo inputs](#github-deployment-repo-inputs)


The following inputs can be used as `step.with` keys
<br/>
<br/>

#### **Action defaults Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout` | Boolean | Set to `false` if the code is already checked out. (Default is `true`). |
| `bitops_code_only` | Boolean | If `true`, will run only the generation phase of BitOps, where the Terraform and Ansible code is built. |
| `bitops_code_store` | Boolean | Set to `true` to create a GitHub artifact with the BitOps generated code. Contains all Terraform and Ansible code. |
| `ansible_skip` | Boolean | Set to `false` to skip Ansible execution after Terraform excecution. Defaults to `true`. |
| `ansible_ssh_to_private_ip` | Boolean | Make Ansible connect to the private IP of the instance. Only usefull if using a hosted runner in the same network.'  Default is `false`. | 
| `ansible_start_docker_timeout` | String | Ammount of time in seconds it takes Ansible to mark as failed the startup of docker. Defaults to `300`.|
<hr/>
<br/>

#### **AWS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region. Defaults to `us-east-1` |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. Use with destroy to destroy specific resources. |
| `aws_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to all provisioned resources.|
<hr/>
<br/>

#### **Stack managemnet**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `stack_destroy` | Boolean  | Set to `true` to destroy the stack - Will delete the `elb logs bucket` after the destroy action runs. |
| `tf_state_bucket` | String | AWS S3 bucket name to use for Terraform state. See [note](#s3-buckets-naming) | 
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. `stack_destroy` must also be `true`. Default is `false`. |
| `tf_state_file_name` | String | Change this to be anything you want to. Carefull to be consistent here. A missing file could trigger recreation, or stepping over destruction of non-defined objects. Defaults to `tf-state-aws`, `tf-state-ecr` or `tf-state-eks.` |
| `tf_state_file_name_append` | String | Appends a string to the tf-state-file. Setting this to `unique` will generate `tf-state-aws-unique`. (Can co-exist with `tf_state_file_name`) |
| `tf_targets` | List | A list of targets to create before the full stack creation. | 
<hr/>
<br/>

#### **Secrets and Environment Variables Inputs**
| Name             | Type    | Description - Check note about [**environment variables**](#environment-variables). |
|------------------|---------|------------------------------------|
| `repo_env` | String | `.env` file containing environment variables to be used with the app. Name defaults to `repo_env`. |
| `dot_env` | String | `.env` file to be used with the app. This is the name of the [Github secret](https://docs.github.com/es/actions/security-guides/encrypted-secrets). |
| `ghv_env` | String | `.env` file to be used with the app. This is the name of the [Github variables](https://docs.github.com/en/actions/learn-github-actions/variables). |
| `aws_secret_env` | String | Secret name to pull environment variables from AWS Secret Manager. |
<hr/>
<br/>

#### **EC2 Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `ec2_ami_id` | String | AWS AMI ID. Will default to latest Ubuntu 22.04 server image (HVM). Accepts `ami-###` values. |
| `ec2_ami_update` | Boolean | Set this to `true` if you want to recreate the EC2 instance if there is a newer version of the AMI. Defaults to `false`.|
| `ec2_instance_type` | String | The AWS IAM instance type to use. Default is `t2.small`. See [this list](https://aws.amazon.com/ec2/instance-types/) for reference. |
| `ec2_volume_size` | Integer | The size of the volume (in GB) on the AWS Instance. | 
| `ec2_root_preserve` | Boolean | Set this to true to avoid deletion of root volume on termination. Defaults to `false`. | 
| `ec2_security_group_name` | String | The name of the EC2 security group. Defaults to `SG for ${aws_resource_identifier} - EC2`. |

| `ec2_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Default is `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`|
| `ec2_instance_public_ip` | Boolean | Set to enable or not a public facing IP. Needed for Ansible to run after Terraform. Defaults to `true`. |
| `ec2_port_list` | String | Comma separated list of ports to be enabled in the EC2 instance security group. (NOT THE ELB) In a `xx,yy` format. |
| `ec2_user_data_file` | String | Relative path in the repo for a user provided script to be executed with Terraform EC2 Instance creation. See [this note](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts)
| `ec2_user_data_replace_on_change` | Boolean | If `ec2_user_data_file` file changes, instance will stop and start. Hence public IP will change. This will destroy and recreate the instance. Defaults to `true`. If not, action will fail because the EC2 IP will change on stop/start. |
| `ec2_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to ec2 provisioned resources.|
| `create_keypair_sm_entry` | Boolean | Generates and manage a secret manager entry that contains the public and private keys created for the ec2 instance. |
<hr/>
<br/>

#### **Application Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `docker_remove_orphans` | Boolean | Set to `true` to turn the `--remove-orphans` flag. Defaults to `false`. |
| `docker_full_cleanup` | Boolean | Set to `true` to run `docker-compose down` and `docker system prune --all --force --volumes` after. Runs before `docker_install`. WARNING: docker volumes will be destroyed. |
| `docker_cloudwatch_enable` | Boolean | Toggle cloudwatch creation for Docker. Create a file named `docker-daemon.json` in your repo root dir if you need to customize it. Defaults to `false`. Check [docker docs](https://docs.docker.com/config/containers/logging/awslogs/).|
| `docker_cloudwatch_lg_name` | String| Log group name. Will default to `${aws_resource_identifier}-docker-logs` if none. |
| `docker_cloudwatch_skip_destroy` | Boolean | Toggle deletion or not when destroying the stack. Defaults to `false`. |
| `docker_cloudwatch_retention_days` | String | Number of days to retain logs. 0 to never expire. Defaults to `14`. See [note](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days). |
| `app_directory` | String | Relative path for the directory of the app. (i.e. where the `docker-compose.yaml` file is located). This is the directory that is copied into the EC2 instance. Default is `/`, the root of the repository. Add a `.gha-ignore` file with a list of files to be exluded. (Using glob patterns). |
| `app_directory_cleanup` | Boolean | Will generate a timestamped compressed file (in the home directory of the instance) and delete the app repo directory. Runs before `docker_install` and after `docker_full_cleanup`. |
| `docker_efs_mount_target` | String | Directory path within docker env to mount directory to. Default is `/data`|
| `app_port` | String | Port to be expose for the container. Default is `3000` | 
<hr/>
<br/>

#### **Load Balancer Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `lb_create` | Boolean | Set this to false to disable creation of the EC2 instance load balancer (Needed with DNS records).'|
| `lb_port` | String | Load balancer listening port. Default is `80` if NO FQDN provided, `443` if FQDN provided. |
| `lb_healthcheck` | String | Load balancer health check string. Default is `TCP:22`. |
| `lb_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to elb provisioned resources.|
<hr/>
<br/>

#### **VPC Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_vpc_create` | Boolean | Define if a VPC should be created |
| `aws_vpc_name` | String | Define a name for the VPC. Defaults to `VPC for ${aws_resource_identifier}`. |
| `aws_vpc_cidr_block` | String | Define Base CIDR block which is divided into subnet CIDR blocks. Defaults to `10.0.0.0/16`. |
| `aws_vpc_public_subnets` | String | Comma separated list of public subnets. Defaults to `10.10.110.0/24`|
| `aws_vpc_private_subnets` | String | Comma separated list of private subnets. If no input, no private subnet will be created. Defaults to `<none>`. |
| `aws_vpc_availability_zones` | String | Comma separated list of availability zones. Defaults to `aws_default_region+<random>` value. If a list is defined, the first zone will be the one used for the EC2 instance. |
| `aws_vpc_id` | String | EXISTING AWS VPC ID. Accepts `vpc-###` values. |
| `aws_vpc_subnet_id` | String | EXISTING AWS VPC Subnet ID. If none provided, will pick one. (Ideal when there's only one) |
| `aws_vpc_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to vpc provisioned resources.|
<hr/>
<br/>

#### **Certificate Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_r53_enable` | Boolean | Set this to true if you wish to manage certificates through AWS Certificate Manager with Terraform.
| `domain_name` | String | Define the root domain name for the application. e.g. bitovi.com'. |
| `sub_domain` | String | Define the sub-domain part of the URL. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. |
| `root_domain` | Boolean | Deploy application to root domain. Will create root and www records. Default is `false`. |
| `cert_arn` | String | Define the certificate ARN to use for the application. **See note**. |
| `create_root_cert` | Boolean | Generates and manage the root cert for the application. **See note**. Default is `false`. |
| `create_sub_cert` | Boolean | Generates and manage the sub-domain certificate for the application. **See note**. Default is `false`. |
| `enable_cert` | Boolean | Set this to false to use certificate is present for the domain. **See note**. Default is `true`. |
| `r53_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to R53 provisioned resources.|
<hr/>
<br/>

#### **EFS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_efs_create` | Boolean | Toggle to indicate whether to create and EFS and mount it to the ec2 as a part of the provisioning. Note: The EFS will be managed by the stack and will be destroyed along with the stack |
| `aws_efs_create_ha` | Boolean | Toggle to indicate whether the EFS resource should be highly available (target mounts in all available zones within region) |
| `aws_efs_fs_id` | String | ID of existing EFS. |
| `aws_efs_vpc_id` | String | ID of the VPC for the EFS mount target. If aws_efs_create_ha is set to true, will create one mount target per subnet available in the VPC. If not, will create one in an automated selected region. |
| `aws_efs_subnet_ids` | String | ID (or ID's) of the subnet for the EFS mount target. (Comma separated string.) |
| `aws_efs_security_group_name` | String | The name of the EFS security group. Defaults to `SG for ${aws_resource_identifier} - EFS`. |
| `aws_efs_create_replica` | Boolean | Toggle to indiciate whether a read-only replica should be created for the EFS primary file system |
| `aws_efs_replication_destination` | String | AWS Region to target for replication. |
| `aws_efs_enable_backup_policy` | Boolean | Toggle to indiciate whether the EFS should have a backup policy |
| `aws_efs_transition_to_inactive` | String | Indicates how long it takes to transition files to the IA storage class. |
| `aws_efs_mount_target` | String | Directory path in efs to mount directory to. Default is `/`. |
| `aws_efs_ec2_mount_point` | String | The aws_efs_ec2_mount_point input represents the folder path within the EC2 instance to the data directory. Default is `/user/ubuntu/<application_repo>/data`. Additionally this value is loaded into the docker-compose `.env` file as `HOST_DIR`. |
| `aws_efs_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to efs provisioned resources.|
<hr/>
<br/>

#### **RDS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_rds_db_enable`| Boolean | Set to `true` to enable an RDS DB. |
| `aws_rds_db_proxy`| Boolean | Set to `true` to add a RDS DB Proxy. |
| `aws_rds_db_name`| String | The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created in the DB instance. |
| `aws_rds_db_user`| String | Username for the db. Defaults to `dbuser`. |
| `aws_rds_db_engine`| String | Which Database engine to use. Defaults to `postgres`. |
| `aws_rds_db_engine_version`| String | Which Database engine version to use. |
| `aws_rds_db_security_group_name`| String | The name of the database security group. Defaults to `SG for ${aws_resource_identifier} - RDS`. |
| `aws_rds_db_allowed_security_groups` | String | Comma separated list of security groups to add to the DB SG. | 
| `aws_rds_db_ingress_allow_all` | Boolean | Allow incoming traffic from 0.0.0.0/0. Defaults to `true`. |
| `aws_rds_db_publicly_accessible` | Boolean | Allow the database to be publicly accessible. Defaults to `false`. |
| `aws_rds_db_port`| String | Port where the DB listens to. |
| `aws_rds_db_subnets`| String | Specify which subnets to use as a list of strings.  Example: `i-1234,i-5678,i-9101`. |
| `aws_rds_db_allocated_storage`| String | Storage size. Defaults to `10`. |
| `aws_rds_db_max_allocated_storage`| String | Max storage size. Defaults to `0` to disable auto-scaling. |
| `aws_rds_db_instance_class`| String | DB instance server type. Defaults to `db.t3.micro`. |
| `aws_rds_db_final_snapshot` | String | If wanted, add a snapshot name. Leave emtpy if not. |
| `aws_rds_db_restore_snapshot_identifier` | String | Name of the snapshot to create the databse from. |
| `aws_rds_db_cloudwatch_logs_exports`| String | Set of log types to enable for exporting to CloudWatch logs. Defaults to `postgresql`. MySQL and MariaDB: `audit, error, general, slowquery`. PostgreSQL: `postgresql, upgrade`. MSSQL: `agent , error`. Oracle: `alert, audit, listener, trace`. |
| `aws_rds_db_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to RDS provisioned resources.|
<hr/>
<br/>

#### **Aurora Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_aurora_enable` | Boolean | Set to `true` to enable an [Aurora database](https://docs.aws.amazon.com/AmazonRDS/latest/
AuroraUserGuide/CHAP_AuroraOverview.html). (Postgres or MySQL). |
| `aws_aurora_proxy`| Boolean | Set to `true` to add an Aurora DB Proxy |
| `aws_aurora_engine` | String |  Which Database engine to use. Default is `aurora-postgresql`.|
| `aws_aurora_engine_version` | String |  Specify database version.  More information [Postgres](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html) or [MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraMySQLReleaseNotes/Welcome.html). Default is `11.17`. (Postgres) |
| `aws_aurora_database_group_family` | String | Specify aws database group family. Default is `aurora-postgresql11`. See [this](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/rds/create-db-parameter-group.html).|
| `aws_aurora_instance_class` | String | Define the size of the instances in the DB cluster. Default is `db.t3.medium`. | 
| `aws_aurora_security_group_name` | String | The name of the database security group. Defaults to `SG for ${aws_resource_identifier} - Aurora`. |
| `aws_aurora_subnets` | String | Specify which subnets to use as a list of strings.  Example: `i-1234,i-5678,i-9101`. |
| `aws_aurora_cluster_name` | String | Specify a cluster name. Will be created if it does not exist. Defaults to `aws_resource_identifier`. |
| `aws_aurora_database_name` | String | Specify a database name. Will be created if it does not exist. Defaults to `aws_resource_identifier`. |
| `aws_aurora_database_port` | String | Specify a listening port for the database. Default is `5432`.|
| `aws_aurora_restore_snapshot` | String | Restore a snapshot to the DB. Should be set only once. Changes in this value will destroy and recreate the database completely. | 
| `aws_aurora_snapshot_name` | String | Specify a database name. Will be created if it does not exist. Won't overwrite. |
| `aws_aurora_snapshot_overwrite` | Boolean | Set to true to overwrite the snapshot. |
| `aws_aurora_database_protection` | Boolean | Protects the database from deletion. Default is `false`.|
| `aws_aurora_database_final_snapshot` | Boolean | Creates a snapshot before deletion. If a string is passed, it will be used as snapsthot name. Defaults to `false`.|
| `aws_aurora_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to aurora provisioned resources.|
<hr/>
<br/>


#### **GitHub Deployment repo inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `gh_deployment_input_terraform` | String | Folder to store Terraform files to be included during Terraform execution.|
| `gh_deployment_input_ansible` | String | Folder where a whole Ansible structure is expected. If missing bitops.config.yaml a default will be generated.|
| `gh_deployment_input_ansible_playbook` | String | Main playbook to be looked for. Defaults to `playbook.yml`.|
| `gh_deployment_input_ansible_extra_vars_file` | String | Relative path to Ansible extra-vars file. |
| `gh_deployment_action_input_ansible_extra_vars_file` | String | Relative path to Ansible extra-vars file from deployment to be set up into the action Ansible code. |
<hr/>
<br/>

## Note about resource identifiers

Most resources will contain the tag `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`, some of them, even the resource name after. 
We limit this to a 60 characters string because some AWS resources have a length limit and short it if needed.

We use the kubernetes style for this. For example, kubernetes -> k(# of characters)s -> k8s. And so you might see some compressions are made.

For some specific resources, we have a 32 characters limit. If the identifier length exceeds this number after compression, we remove the middle part and replace it for a hash made up from the string itself. 

### S3 buckets naming

Buckets names can be made of up to 63 characters. If the length allows us to add -tf-state, we will do so. If not, a simple -tf will be added.

## CERTIFICATES - Only for AWS Managed domains with Route53

As a default, the application will be deployed and the ELB public URL will be displayed.

If `domain_name` is defined, we will look up for a certificate with the name of that domain (eg. `example.com`). We expect that certificate to contain both `example.com` and `*.example.com`. 

If you wish to set up `domain_name` and disable the certificate lookup, set up `enable_cert` to false.

Setting `create_root_cert` to `true` will create this certificate with both `example.com` and `*.example.com` for you, and validate them. (DNS validation).

Setting `create_sub_cert` to `true` will create a certificate **just for the subdomain**, and validate it.

> :warning: Be very careful here! **Created certificates are fully managed by Terraform**. Therefor **they will be destroyed upon stack destruction**.

To change a certificate (root_cert, sub_cert, ARN or pre-existing root cert), you must first set the `enable_cert` flag to false, run the action, then set the `enable_cert` flag to true, add the desired settings and excecute the action again. (**This will destroy the first certificate.**)

This is necessary due to a limitation that prevents certificates from being changed while in use by certain resources.

## Adding external datastore (AWS EFS)
Users looking to add non-ephemeral storage to their created EC2 instance have the following options; create a new efs as a part of the ec2 deployment stack, or mounting an existing EFS. 

### 1. Create EFS

Option 1, you have access to the `aws_efs_create` attribute which will create a EFS resource and mount it to the EC2 instance in the application directory at the path: "app_root/data".

> :warning: Be very careful here! The **EFS is fully managed by Terraform**. Therefor **it will be destroyed upon stack destruction**.

### 2. Mount EFS
Option 2, you have access to the `aws_efs_fs_id` attributes, which will mount an existing EFS Volume. 

## Adding external Aurora database (AWS RDS)

If `aws_aurora_enable` is set to `true`, this action will deploy an RDS cluster for Postgres as a default. 

### Environment variables
The following environment variables are added to the `.env` file in your app's `docker-compose.yaml` file.

To take advantage of these environment variables, be sure your docker-compose file is referencing the `.env` file like this:
```
version: '3.9'
services:
  app:
    # ...
    env_file: .env
    # ...
```

The available environment variables are:
| Variable | Description |
|----------|-------------|
| `AURORA_CLUSTER_ENGINE` (and `DBA_ENGINE`) | Engine name - ( mysql/postgres ) |
| `AURORA_CLUSTER_ENDPOINT` (and `DBA_HOST`) | Writer endpoint for the cluster |
| `AURORA_CLUSTER_PORT` (and `DBA_PORT`) | The database port |
| `AURORA_CLUSTER_MASTER_PASSWORD` (and `DBA_PASSWORD`) | database root password |
| `AURORA_CLUSTER_MASTER_USERNAME` (and `DBA_USER`) | The database master username |
| `AURORA_CLUSTER_DATABASE_NAME` (and `DBA_NAME`) | Name for an automatically created database on cluster creation |
| `AURORA_CLUSTER_ARN` | Amazon Resource Name (ARN) of cluster |
| `AURORA_CLUSTER_ID` | The RDS Cluster Identifier |
| `AURORA_CLUSTER_RESOURCE_ID` | The RDS Cluster Resource ID |
| `AURORA_CLUSTER_READER_ENDPOINT` | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| `AURORA_CLUSTER_ENGINE_VERSION_ACTUAL` | The running version of the cluster database |
| `AURORA_CLUSTER_HOSTED_ZONE_ID`| The Route53 Hosted Zone ID of the endpoint |

### AWS Root Certs
The AWS root certificate is downloaded and accessible via the `rds-combined-ca-bundle.pem` file in root of your app repo/directory.

### App example
Example JavaScript to make a request to the Postgres cluster:

```js
const { Client } = require('pg')

// set up client
const client = new Client({
  host: process.env.DBA_HOST,
  port: process.env.DBA_PORT,
  user: process.env.DBA_USER,
  password: process.env.DBA_PASSWORD,
  database: process.env.DBA_NAME,
  ssl: {
    ca: fs.readFileSync('rds-combined-ca-bundle.pem').toString()
  }
});

// connect and query
client.connect()
const result = await client.query('SELECT NOW()');
await client.end();

console.log(`Hello SQL timestamp: ${result.rows[0].now}`);
```

### Aurora Infrastructure and Cluster Details
Specifically, the following resources will be created:
- AWS Security Group
  - AWS Security Group Rule - Allows access to the cluster's db port: `5432`
- AWS RDS Aurora
  - Includes a single database (set by the input: `aws_aurora_database_name`. defaults to `root`)

Additional details about the cluster that's created:
- Automated backups (7 Days)
  - Backup window 2-3 UTC (GMT)
- Encrypted Storage
- Monitoring enabled
- Sends logs to AWS Cloudwatch


> _**For more details**, see [operations/deployment/terraform/postgres.tf](operations/deployment/terraform/postgres.tf)_

## Made with BitOps
[BitOps](https://bitops.sh) allows you to define Infrastructure-as-Code for multiple tools in a central place.  This action uses a BitOps [Operations Repository](https://bitops.sh/operations-repo-structure/) to set up the necessary Terraform and Ansible to create infrastructure and deploy to it.

## Contributing
We would love for you to contribute to [bitovi/github-actions-deploy-docker-to-ec2](https://github.com/bitovi/github-actions-deploy-docker-to-ec2).
Would you like to see additional features?  [Create an issue](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/issues/new) or a [Pull Requests](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/pulls). We love discussing solutions!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/main/LICENSE).

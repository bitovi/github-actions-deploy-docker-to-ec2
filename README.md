# Deploy Docker to AWS VM (EC2)

`bitovi/github-actions-deploy-docker-to-ec2` deploys any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an AWS VM (EC2) using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker compose up`.

## Action Summary
This action will create an EC2 instance and the resources defined, copy this repo to the VM, install docker (and other options if enabled) and then run `docker compose up`.

If you would like to deploy a backend app/service, check out our other actions:
| Action | Purpose |
| ------ | ------- |
| [Deploy an AWS ECS Cluster](https://github.com/marketplace/actions/deploy-an-aws-ecs-cluster) | Deploys an ECS (Fargate or EC2) cluster, with tasks and service definitions (and more!)|
| [Deploy Storybook to GitHub Pages](https://github.com/marketplace/actions/deploy-storybook-to-github-pages) | Builds and deploys a Storybook application to GitHub Pages. |
| [Deploy static site to AWS (S3/CDN/R53)](https://github.com/marketplace/actions/deploy-static-site-to-aws-s3-cdn-r53) | Hosts a static site in AWS S3 with CloudFront |
<br/>

**And more!**, check our [list of actions in the GitHub marketplace](https://github.com/marketplace?category=&type=actions&verification=&query=bitovi)

## Getting Started Intro Video
[![Getting Started - Youtube](https://img.youtube.com/vi/oya5LuHUCXc/0.jpg)](https://www.youtube.com/watch?v=oya5LuHUCXc)

## Need help or have questions?
This project is supported by [Bitovi, a DevOps Consultancy](https://www.bitovi.com/devops-consulting) and a proud supporter of Open Source software.

You can **get help or ask questions** on our [Discord channel](https://discord.gg/J7ejFsZnJ4)! Come hang out with us!

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/devops-consulting).

# WHAT'S NEW IN V1 - What changed? 

A lot! The whole code supporting this action migrated into a bigger repo, with more modules and functions. We concentrated our work there, hence any improvement done there benefits all of our actions.

Actions you said? Yes… go check our [list of actions in the GitHub marketplace](https://github.com/marketplace?category=&type=actions&verification=&query=bitovi)

New stuff! To name a few, cloudwatch for docker, VPC handling, EC2/ELB/APP port list, user_data for pre-ansible run, RDS (as Aurora replacement) among others. Check the [v1-changes](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/commons/v1-changes.md) doc.

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
We accept multiple ways to add environment variables. All of them will be merged into a .env file in the EC2 instance in a `KEY=VALUE` format. 
For secrects stored in AWS Secrets Manager we expect them to be in a JSON format. (Like `'{"key":"value"}'`)
The rest could be in KEY=VALUE format. 

### You can provide:
 - `env_aws_secret` - Comma separated list of secret name(s) stored in AWS Secrets Manager
 - `env_repo` - A file in your repo that contains env vars. Defaults to `repo_env`.`
 - `env_ghv` - An entry in [Github actions variables](https://docs.github.com/en/actions/learn-github-actions/variables)
 - `env_ghs` - An entry in [Github secrets](https://docs.github.com/es/actions/security-guides/encrypted-secrets)
 
### To use them in your docker-compose file, you can do so by adding the following: 
```
version: '3.9'
services:
  app:
    env_file: .env
```

These environment variables are merged to the .env file quoted in the following order:
 - Terraform passed env vars ( This is not optional nor customizable )
 - Repository checked-in env vars - repo_env file as default. (KEY=VALUE style)
 - Github Vars - Create a variable in your GH Repo - (KEY=VALUE style)
 - Github Secret - Create a secret in your GH Repo - (KEY=VALUE style)
 - AWS Secret - Comma separated list of JSON style like '{"key":"value"}' secrets.

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

          aws_elb_app_port: 8080 # This should match the docker exposed port. 
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
      name: "EC2"
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
        aws_additional_tags: '{\"key\":\"value\",\"key2\":\"value2\"}'

        aws_r53_enable: true
        aws_r53_domain_name: bitovi.com
        aws_r53_sub_domain_name: app
        aws_r53_create_sub_cert: true

        tf_state_bucket: my-terraform-state-bucket
        ansible_start_docker_timeout: 600

        env_ghs: ${{ secrets.DOT_ENV }}
        env_ghv: ${{ vars.VARS }}
        env_aws_secret: some-secret,some-other
        aws_elb_app_port: 3000,8080
        aws_elb_listen_port: 443,8080
        aws_elb_healthcheck: "HTTP:8080"
        
        docker_cloudwatch_enable: true
        docker_cloudwatch_retention_days: 7

        aws_rds_db_enable: true
```

## Customizing

### Inputs
1. [AWS Specific](#aws-specific)
1. [GitHub Commons main inputs](#github-commons-main-inputs)
1. [Secrets and Environment Variables](#secrets-and-environment-variables-inputs)
1. [EC2](#ec2-inputs)
1. [VPC](#vpc-inputs)
1. [AWS Route53 Domains and Certificates](#aws-route53-domains-and-certificate-inputs)
1. [Load Balancer](#load-balancer-inputs)
1. [Docker](#docker-inputs)
1. [EFS](#efs-inputs)
1. [RDS](#rds-inputs)
1. [DB Proxy](#db-proxy-inputs)
1. [GitHub Deployment repo inputs](#github-deployment-repo-inputs)

The following inputs can be used as `step.with` keys
<br/>
<br/>

#### **AWS Specific**
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

#### **GitHub Commons main inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout` | Boolean | Set to `false` if the code is already checked out. (Default is `true`). |
| `bitops_code_only` | Boolean | If `true`, will run only the generation phase of BitOps, where the Terraform and Ansible code is built. |
| `bitops_code_store` | Boolean | Store BitOps generated code as a GitHub artifact. |
| `tf_stack_destroy` | Boolean  | Set to `true` to destroy the stack - Will delete the `elb logs bucket` after the destroy action runs. |
| `tf_state_file_name` | String | Change this to be anything you want to. Carefull to be consistent here. A missing file could trigger recreation, or stepping over destruction of non-defined objects. Defaults to `tf-state-aws`, `tf-state-ecr` or `tf-state-eks.` |
| `tf_state_file_name_append` | String | Appends a string to the tf-state-file. Setting this to `unique` will generate `tf-state-aws-unique`. (Can co-exist with `tf_state_file_name`) |
| `tf_state_bucket` | String | AWS S3 bucket name to use for Terraform state. See [note](#s3-buckets-naming) | 
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. `tf_stack_destroy` must also be `true`. Default is `false`. |
| `tf_targets` | List | A list of targets to create before the full stack creation. | 
| `ansible_skip` | Boolean | Skip Ansible execution after Terraform excecution. Default is `false`.|
| `ansible_ssh_to_private_ip` | Boolean | Make Ansible connect to the private IP of the instance. Only usefull if using a hosted runner in the same network.'  Default is `false`. | 
| `ansible_start_docker_timeout` | String | Ammount of time in seconds it takes Ansible to mark as failed the startup of docker. Defaults to `300`.|
<hr/>
<br/>

#### **Secrets and Environment Variables Inputs**
| Name             | Type    | Description - Check note about [**environment variables**](#environment-variables). |
|------------------|---------|------------------------------------|
| `env_aws_secret` | String | Secret name to pull environment variables from AWS Secret Manager. Accepts comma separated list of secrets. |
| `env_repo` | String | `.env` file containing environment variables to be used with the app. Name defaults to `repo_env`. |
| `env_ghs` | String | `.env` file to be used with the app. This is the name of the [Github secret](https://docs.github.com/es/actions/security-guides/encrypted-secrets). |
| `env_ghv` | String | `.env` file to be used with the app. This is the name of the [Github variables](https://docs.github.com/en/actions/learn-github-actions/variables). |
<hr/>
<br/>

#### **EC2 Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_ec2_instance_create` | Boolean | Set to `true` if you wish to create an EC2 instance. (Default is `false`). |
| `aws_ec2_ami_filter` | String | AWS AMI Filter string. Will be used to lookup for lates image based on the string. Defaults to `ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*`.' |
| `aws_ec2_ami_owner` | String | 'Owner of AWS AMI image. This ensures the provider is the one we are looking for. Defaults to `099720109477`, Canonical (Ubuntu).' |
| `aws_ec2_ami_id` | String | AWS AMI ID. Will default to the latest Ubuntu 22.04 server image (HVM). Accepts `ami-###` values. |
| `aws_ec2_ami_update` | Boolean | Set this to `true` if you want to recreate the EC2 instance if there is a newer version of the AMI. Defaults to `false`.|
| `aws_ec2_instance_type` | String | The AWS IAM instance type to use. Default is `t2.small`. See [this list](https://aws.amazon.com/ec2/instance-types/) for reference. |
| `aws_ec2_instance_root_vol_size` | Integer | Define the volume size (in GiB) for the root volume on the AWS Instance. Defaults to `8`. | 
| `aws_ec2_instance_root_vol_preserve` | Boolean | Set this to true to avoid deletion of root volume on termination. Defaults to `false`. | 
| `aws_ec2_security_group_name` | String | The name of the EC2 security group. Defaults to `SG for ${aws_resource_identifier} - EC2`. |
| `aws_ec2_iam_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Will create one if none provided with the name`${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. |
| `aws_ec2_create_keypair_sm` | Boolean | Generates and manages a secret manager entry that contains the public and private keys created for the ec2 instance. |
| `aws_ec2_instance_public_ip` | Boolean | Add a public IP to the instance or not. (Not an Elastic IP). |
| `aws_ec2_port_list` | String | Comma separated list of ports to be enabled in the EC2 instance security group. (NOT THE ELB) In a `xx,yy` format. |
| `aws_ec2_user_data_file` | String | Relative path in the repo for a user provided script to be executed with Terraform EC2 Instance creation. See [this note](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html#user-data-shell-scripts) |
| `aws_ec2_user_data_replace_on_change`| Boolean | If `aws_ec2_user_data_file` file changes, instance will stop and start. Hence public IP will change. This will destroy and recreate the instance. Defaults to `true`. |
| `aws_ec2_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to ec2 provisioned resources.|
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
| `aws_vpc_id` | String | AWS VPC ID. Accepts `vpc-###` values. |
| `aws_vpc_subnet_id` | String | AWS VPC Subnet ID. If none provided, will pick one. (Ideal when there's only one) |
| `aws_vpc_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to vpc provisioned resources.|
<hr/>
<br/>

#### **AWS Route53 Domains and Certificate Inputss**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_r53_enable` | Boolean | Set this to true if you wish to manage certificates through AWS Certificate Manager with Terraform. **See note**. Default is `false`. |
| `aws_r53_domain_name` | String | Define the root domain name for the application. e.g. bitovi.com'. |
| `aws_r53_sub_domain_name` | String | Define the sub-domain part of the URL. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. |
| `aws_r53_root_domain_deploy` | Boolean | Deploy application to root domain. Will create root and www records. Default is `false`. |
| `aws_r53_enable_cert` | Boolean | Set this to true if you wish to manage certificates through AWS Certificate Manager with Terraform. **See note**. Default is `false`. | 
| `aws_r53_cert_arn` | String | Define the certificate ARN to use for the application. **See note**. |
| `aws_r53_create_root_cert` | Boolean | Generates and manage the root cert for the application. **See note**. Default is `false`. |
| `aws_r53_create_sub_cert` | Boolean | Generates and manage the sub-domain certificate for the application. **See note**. Default is `false`. |
| `aws_r53_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to R53 provisioned resources.|
<hr/>
<br/>

#### **Load Balancer Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_elb_create` | Boolean | Toggles the creation of a load balancer and map ports to the EC2 instance. Defaults to `true`.|
| `aws_elb_security_group_name` | String | The name of the ELB security group. Defaults to `SG for ${aws_resource_identifier} - ELB`. |
| `aws_elb_app_port` | String | Port in the EC2 instance to be redirected to. Default is `3000` | 
| `aws_elb_app_protocol` | String | Protocol to enable. Could be HTTP, HTTPS, TCP or SSL. Defaults to TCP. |
| `aws_elb_listen_port` | String | Load balancer listening port. Default is `80` if NO FQDN provided, `443` if FQDN provided. |
| `aws_elb_listen_protocol` | String | Protocol to enable. Could be HTTP, HTTPS, TCP or SSL. Defaults to `TCP` if NO FQDN provided, `SSL` if FQDN provided. |
| `aws_elb_healthcheck` | String | Load balancer health check string. Default is `TCP:22`. |
| `aws_elb_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to elb provisioned resources.|
<hr/>
<br/>


#### **Docker Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `docker_install` | Boolean | Set to `true` to enable docker installation through Ansible. `docker-compose up` will be excecuted after. |
| `docker_remove_orphans` | Boolean | Set to `true` to turn the `--remove-orphans` flag. Defaults to `false`. |
| `docker_full_cleanup` | Boolean | Set to `true` to run `docker-compose down` and `docker system prune --all --force --volumes` after. Runs before `docker_install`. WARNING: docker volumes will be destroyed. |
| `docker_repo_app_directory` | String | Relative path for the directory of the app. (i.e. where the `docker-compose.yaml` file is located). This is the directory that is copied into the EC2 instance. Default is `/`, the root of the repository. Add a `.gha-ignore` file with a list of files to be exluded. (Using glob patterns). |
| `docker_repo_app_directory_cleanup` | Boolean | Will generate a timestamped compressed file (in the home directory of the instance) and delete the app repo directory. Runs before `docker_install` and after `docker_full_cleanup`. |
| `docker_efs_mount_target` | String | Directory path within docker env to mount directory to. Default is `/data`|
| `docker_cloudwatch_enable` | Boolean | Toggle cloudwatch creation for Docker. Create a file named `docker-daemon.json` in your repo root dir if you need to customize it. Defaults to `false`. Check [docker docs](https://docs.docker.com/config/containers/logging/awslogs/).|
| `docker_cloudwatch_lg_name` | String| Log group name. Will default to `${aws_resource_identifier}-docker-logs` if none. |
| `docker_cloudwatch_skip_destroy` | Boolean | Toggle deletion or not when destroying the stack. Defaults to `false`. |
| `docker_cloudwatch_retention_days` | String | Number of days to retain logs. 0 to never expire. Defaults to `14`. See [note](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days). |
<hr/>
<br/>

#### **EFS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_efs_create` | Boolean | Toggle to indicate whether to create an EFS and mount it to the ec2 as a part of the provisioning. Note: The stack will manage the EFS and will be destroyed along with the stack. |
| `aws_efs_create_ha` | Boolean | Toggle to indicate whether the EFS resource should be highly available (target mounts in all available zones within a region). |
| `aws_efs_fs_id` | String | ID of existing EFS. |
| `aws_efs_vpc_id` | String | ID of the VPC for the EFS mount target. If aws_efs_create_ha is set to true, will create one mount target per subnet available in the VPC. If not, will create one in an automated selected region. |
| `aws_efs_subnet_ids` | String | ID (or ID's) of the subnet for the EFS mount target. (Comma separated string.) |
| `aws_efs_security_group_name` | String | The name of the EFS security group. Defaults to `SG for ${aws_resource_identifier} - EFS`. |
| `aws_efs_create_replica` | Boolean | Toggle whether a read-only replica should be created for the EFS primary file system |
| `aws_efs_replication_destination` | String | AWS Region to target for replication. |
| `aws_efs_enable_backup_policy` | Boolean | Toggle whether the EFS should have a backup policy. |
| `aws_efs_transition_to_inactive` | String | Indicates how long it takes to transition files to the IA storage class. |
| `aws_efs_mount_target` | String | Directory path in efs to mount directory to. Default is `/`. |
| `aws_efs_ec2_mount_point` | String | The aws_efs_ec2_mount_point input represents the folder path within the EC2 instance to the data directory. Default is `/user/ubuntu/<application_repo>/data`. Additionally, this value is loaded into the docker-compose `.env` file as `HOST_DIR`. |
| `aws_efs_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to efs provisioned resources.|
<hr/>
<br/>

#### **RDS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_rds_db_enable`| Boolean | Set to `true` to enable an RDS DB. |
| `aws_rds_db_proxy`| Boolean | Set to `true` to add a RDS DB Proxy. |
| `aws_rds_db_identifier`| String | Database identifier that will appear in the AWS Console. Defaults to `aws_resource_identifier` if none set. |
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

#### **DB Proxy Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_db_proxy_name` | String | Name of the database proxy.  Defaults to `aws_resource_identifier` |
| `aws_db_proxy_client_password_auth_type` | String | Overrides auth type. Using `MYSQL_NATIVE_PASSWORD`, `POSTGRES_SCRAM_SHA_256`, and `SQL_SERVER_AUTHENTICATION` depending on the database family. |
| `aws_db_proxy_tls` | Boolean | Make TLS a requirement for connections. Defaults to `true`.|
| `aws_db_proxy_security_group_name` | String | Name for the proxy security group. Defaults to `aws_resource_identifier`. |
| `aws_db_proxy_database_security_group_allow` | Boolean | If true, will add an incoming rule from every security group associated with the DB. |
| `aws_db_proxy_allowed_security_group` | String | Comma separated list fo allowed security groups to add.|
| `aws_db_proxy_allow_all_incoming` | Boolean | Allow all incoming traffic to the DB Proxy. Mind that the proxy is only available from the internal network except manually exposed. | 
| `aws_db_proxy_cloudwatch_enable` | Boolean | Toggle Cloudwatch logs. Will be stored in `/aws/rds/proxy/rds_proxy.name`. |
| `aws_db_proxy_cloudwatch_retention_days` | String | Number of days to retain cloudwatch logs. Defaults to `14`. |
| `aws_db_proxy_additional_tags` | JSON | Add additional tags to the ter added to aurora provisioned resources.|
<br/>
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

If `aws_r53_enable` and `aws_r53_enable_cert` are true, we will look up for a certificate with the name of the domain defined in `aws_r53_domain_name`. (eg. `example.com`). We expect that certificate to contain both `example.com` and `*.example.com`. 

Setting `aws_r53_create_root_cert` to `true` will create this certificate with both `example.com` and `*.example.com` for you, and validate them. (DNS validation).

Setting `aws_r53_create_sub_cert` to `true` will create a certificate **just for the subdomain**, and validate it.

> :warning: Be very careful here! **Created certificates are fully managed by Terraform**. Therefor **they will be destroyed upon stack destruction**.

To change a certificate (root_cert, sub_cert, ARN or pre-existing root cert), you must first toogle  `aws_r53_enable_cert` to false, run the action, and then set the `aws_r53_enable_cert` flag to true, add the desired settings and excecute the action again. (**This will destroy the first certificate.**)

This is necessary due to a limitation that prevents certificates from being changed while in use by certain resources.

## Adding external datastore (AWS EFS)
Users looking to add non-ephemeral storage to their created EC2 instance have the following options; create a new efs as a part of the ec2 deployment stack, or mounting an existing EFS. 

### 1. Create EFS

Option 1, you have access to the `aws_efs_create` attribute which will create a EFS resource and mount it to the EC2 instance in the application directory at the path: "app_root/data".

> :warning: Be very careful here! The **EFS is fully managed by Terraform**. Therefor **it will be destroyed upon stack destruction**.

### 2. Mount EFS
Option 2, you have access to the `aws_efs_fs_id` attributes, which will mount an existing EFS Volume. 

## Adding external RDS Database

If `aws_rds_db_enable` is set to `true`, this action will deploy a Postgres RDS database. 
Connection details will be present in the docker .env file.
> :warning: Database will be created and destroyed with the action. If you wish to use it in a separated repo, you can use our specific [RDS action](https://github.com/marketplace/actions/deploy-amazon-rds-db-instance) and add the secret as input here. 

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
| DB_ENGINE | DB Engine name |
| DB_ENGINE_VERSION | DB Engine version |
| DB_USER | DB Username |
| DB_PASSWORD | DB Password |
| DB_NAME | DB Name (if any created) |
| DB_PORT | DB Port |
| DB_HOST | DB Hostname |

### AWS Root Certs
The AWS root certificate is downloaded and accessible via the `rds-combined-ca-bundle.pem` file in root of your app repo/directory.

### App example
Example JavaScript to make a request to the Postgres cluster:

```js
const { Client } = require('pg')

// set up client
const client = new Client({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
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

## Made with BitOps
[BitOps](https://bitops.sh) allows you to define Infrastructure-as-Code for multiple tools in a central place.  This action uses a BitOps [Operations Repository](https://bitops.sh/operations-repo-structure/) to set up the necessary Terraform and Ansible to create infrastructure and deploy to it.

## Contributing
We would love for you to contribute to [bitovi/github-actions-deploy-docker-to-ec2](https://github.com/bitovi/github-actions-deploy-docker-to-ec2).
Would you like to see additional features?  [Create an issue](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/issues/new) or a [Pull Requests](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/pulls). We love discussing solutions!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/main/LICENSE).

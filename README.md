# Docker to AWS VM

GitHub action to deploy any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an AWS VM (EC2) using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker-compose up`.

## Getting Started Intro Video
[![Getting Started - Youtube](https://img.youtube.com/vi/oya5LuHUCXc/0.jpg)](https://www.youtube.com/watch?v=oya5LuHUCXc)


## Need help or have questions?
This project is supported by [Bitovi, a DevOps Consultancy](https://www.bitovi.com/devops-consulting) and a proud supporter of Open Source software.

You can **get help or ask questions** on our [Discord channel](https://discord.gg/J7ejFsZnJ4)! Come hang out with us!

Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/devops-consulting).


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

Create `.github/workflows/deploy.yaml` with the following to build on push.

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
        uses: bitovi/github-actions-deploy-docker-to-ec2@v0.5.8
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
      uses: bitovi/github-actions-deploy-docker-to-ec2@v0.5.8
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
        additional_tags: "{\"key1\": \"value1\",\"key2\": \"value2\"}"

```

## Customizing

### Inputs
1. [Action Defaults](#action-defaults-inputs)
1. [Secrets and Environment Variables](#secrets-and-environment-variables-inputs)
1. [EC2](#ec2-inputs)
1. [EFS](#efs-inputs)
1. [RDS](#rds-inputs)
1. [Certificates](#certificate-inputs)
1. [Load Balancer](#load-balancer-inputs)
1. [Application](#application-inputs)
1. [Deployment](#deployment-inputs)

The following inputs can be used as `step.with` keys
<br/>
<br/>

#### **Action defaults Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout` | Boolean | Set to `false` if the code is already checked out. (Default is `true`). |
| `stack_destroy` | Boolean  | Set to `true` to destroy the stack - Will delete the `elb logs bucket` after the destroy action runs. |
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region. Defaults to `us-east-1` |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. Use with destroy to destroy specific resources. |
<hr/>
<br/>

#### **Secrets and Environment Variables Inputs**
| Name             | Type    | Description - Check note about [**environment variables**](#environment-variables). |
|------------------|---------|------------------------------------|
| `aws_secret_env` | String | Secret name to pull environment variables from AWS Secret Manager. |
| `repo_env` | String | `.env` file containing environment variables to be used with the app. Name defaults to `repo_env`. |
| `dot_env` | String | `.env` file to be used with the app. This is the name of the [Github secret](https://docs.github.com/es/actions/security-guides/encrypted-secrets). |
| `ghv_env` | String | `.env` file to be used with the app. This is the name of the [Github variables](https://docs.github.com/en/actions/learn-github-actions/variables). |
<hr/>
<br/>

#### **EC2 Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_ami_id` | String | AWS AMI ID. Will default to latest Ubuntu 22.04 server image (HVM). Accepts `ami-###` values. |
| `ec2_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Default is `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`|
| `ec2_instance_type` | String | The AWS IAM instance type to use. Default is `t2.small`. See [this list](https://aws.amazon.com/ec2/instance-types/) for reference. |
| `ec2_volume_size` | Integer | The size of the volume (in GB) on the AWS Instance. | 
| `create_keypair_sm_entry` | Boolean | Generates and manage a secret manager entry that contains the public and private keys created for the ec2 instance. |
<hr/>
<br/>

#### **EFS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_create_efs` | Boolean | Toggle to indicate whether to create and EFS and mount it to the ec2 as a part of the provisioning. Note: The EFS will be managed by the stack and will be destroyed along with the stack |
| `aws_create_ha_efs` | Boolean | Toggle to indicate whether the EFS resource should be highly available (target mounts in all available zones within region) |
| `aws_create_efs_replica` | Boolean | Toggle to indiciate whether a read-only replica should be created for the EFS primary file system |
| `aws_enable_efs_backup_policy` | Boolean | Toggle to indiciate whether the EFS should have a backup policy |
| `aws_efs_zone_mapping` | JSON | Zone Mapping in the form of `{\"<availabillity zone>\":{\"subnet_id\":\"subnet-abc123\", \"security_groups\":\[\"sg-abc123\"\]} }` |
| `aws_efs_transition_to_inactive` | String | Indicates how long it takes to transition files to the IA storage class. |
| `aws_replication_configuration_destination` | String | AWS Region to target for replication. |
| `aws_mount_efs_id` | String | ID of existing EFS. |
| `aws_mount_efs_security_group_id` | String | ID of the primary security group used by the existing EFS. |
| `application_mount_target` | String | The application_mount_target input represents the folder path within the EC2 instance to the data directory. Default is `/user/ubuntu/<application_repo>/data`. Additionally this value is loaded into the docker-compose `.env` file as `HOST_DIR`. |
| `data_mount_target` | String | The data_mount_target input represents the target volume directory within the docker compose container. Default is `/data`. Additionally this value is loaded into the docker-compose container `.env` file as `TARGET_DIR`. |
| `efs_mount_target` | String | Directory path in efs to mount directory to. Default is `/`. |
<hr/>
<br/>

#### **RDS Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_enable_postgres` | Boolean | Set to "true" to enable a postgres database. |
| `aws_postgres_engine` | String |  Which Database engine to use. Default is `aurora-postgresql`.|
| `aws_postgres_engine_version` | String |  Specify Postgres version.  More information [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.20180305.html). Default is `11.13`. |
| `aws_postgres_instance_class` | String | Define the size of the instances in the DB cluster. Default is `db.t3.medium`. | 
| `aws_postgres_subnets` | String | Specify which subnets to use as a list of strings.  Example: `i-1234,i-5678,i-9101`. |
| `aws_postgres_database_name` | String | Specify a database name. Will be created if it does not exist. Default is `root`. |
| `aws_postgres_database_port` | String | Specify a listening port for the database. Default is `5432`.|
| `aws_postgres_database_group_family` | String | Specify aws postgres group family. Default is `aurora-postgresql11`. See [this](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/rds/create-db-parameter-group.html).|
| `aws_postgres_database_protection` | Boolean | Protects the database from deletion. Default is `false`.|
| `aws_postgres_database_final_snapshot` | Boolean | Creates a snapshot before deletion. If a string is passed, it will be used as snapsthot name. Defaults to `false`.|
<hr/>
<br/>

#### **Certificate Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `domain_name` | String | Define the root domain name for the application. e.g. bitovi.com'. |
| `sub_domain` | String | Define the sub-domain part of the URL. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. |
| `root_domain` | Boolean | Deploy application to root domain. Will create root and www records. Default is `false`. |
| `cert_arn` | String | Define the certificate ARN to use for the application. **See note**. |
| `create_root_cert` | Boolean | Generates and manage the root cert for the application. **See note**. Default is `false`. |
| `create_sub_cert` | Boolean | Generates and manage the sub-domain certificate for the application. **See note**. Default is `false`. |
| `no_cert` | Boolean | Set this to true if no certificate is present for the domain. **See note**. Default is `false`. |
<hr/>
<br/>

#### **Load Balancer Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `lb_port` | String | Load balancer listening port. Default is `80` if NO FQDN provided, `443` if FQDN provided. |
| `lb_healthcheck` | String | Load balancer health check string. Default is `HTTP:app_port`. |
<hr/>
<br/>

#### **Application Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `docker_remove_orphans` | Boolean | Set to `true` to turn the `--remove-orphans` flag. Defaults to `false`. |
| `docker_full_cleanup` | Boolean | Set to `true` to run `docker-compose down` and `docker system prune --all --force --volumes` after. Runs before `docker_install`. WARNING: docker volumes will be destroyed. |
| `app_directory` | String | Relative path for the directory of the app. (i.e. where the `docker-compose.yaml` file is located). This is the directory that is copied into the EC2 instance. Default is `/`, the root of the repository. Add a `.gha-ignore` file with a list of files to be exluded. (Using glob patterns). |
| `app_directory_cleanup` | Boolean | Will generate a timestamped compressed file (in the home directory of the instance) and delete the app repo directory. Runs before `docker_install` and after `docker_full_cleanup`. |
| `app_port` | String | Port to be expose for the container. Default is `3000` | 
<hr/>
<br/>

#### **Deployment Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `tf_state_bucket` | String | AWS S3 bucket name to use for Terraform state. See [note](#s3-buckets-naming) | 
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. `stack_destroy` must also be `true`. Default is `false`. |
| `additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to all provisioned resources.|
| `ansible_start_docker_timeout` | String | Ammount of time in seconds it takes Ansible to mark as failed the startup of docker. Defaults to `300`.|
<hr/>
<br/>
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

If you wish to set up `domain_name` and disable the certificate lookup, set up `no_cert` to true.

Setting `create_root_cert` to `true` will create this certificate with both `example.com` and `*.example.com` for you, and validate them. (DNS validation).

Setting `create_sub_cert` to `true` will create a certificate **just for the subdomain**, and validate it.

> :warning: Be very careful here! **Created certificates are fully managed by Terraform**. Therefor **they will be destroyed upon stack destruction**.

To change a certificate (root_cert, sub_cert, ARN or pre-existing root cert), you must first set the `no_cert` flag to true, run the action, then set the `no_cert` flag to false, add the desired settings and excecute the action again. (**This will destroy the first certificate.**)

This is necessary due to a limitation that prevents certificates from being changed while in use by certain resources.

## Adding external datastore (AWS EFS)
Users looking to add non-ephemeral storage to their created EC2 instance have the following options; create a new efs as a part of the ec2 deployment stack, or mounting an existing EFS. 

### 1. Create EFS

Option 1, you have access to the `create_efs` attribute which will create a EFS resource and mount it to the EC2 instance in the application directory at the path: "app_root/data".

> :warning: Be very careful here! The **EFS is fully managed by Terraform**. Therefor **it will be destroyed upon stack destruction**.

### 2. Mount EFS
Option 2, you have access to the `mount_efs` attributes. Requiring an existing EFS id and optionally a primary security group id the existing EFS will be attached to the ec2 security group to allow traffic.

### EFS Zone Mapping
An example EFS Zone mapping;
```
{
  "a": {
    "subnet_id": "subnet-foo123",
    "security_groups: ["sg-foo123", "sg-bar456"]
  }
}
```

## Adding external Postgres database (AWS RDS)

If `aws_enable_postgres` is set to `true`, this action will deploy an RDS cluster for Postgres.

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
| `POSTGRES_CLUSTER_ENDPOINT` (and `PGHOST`) | Writer endpoint for the cluster |
| `POSTGRES_CLUSTER_PORT` (and `PGPORT`) | The database port |
| `POSTGRES_CLUSTER_MASTER_PASSWORD` (and `PG_PASSWORD`) | database root password |
| `POSTGRES_CLUSTER_MASTER_USERNAME` (and `PG_USER`) | The database master username |
| `POSTGRES_CLUSTER_DATABASE_NAME` (and `PGDATABASE`) | Name for an automatically created database on cluster creation |
| `POSTGRES_CLUSTER_ARN` | Amazon Resource Name (ARN) of cluster |
| `POSTGRES_CLUSTER_ID` | The RDS Cluster Identifier |
| `POSTGRES_CLUSTER_RESOURCE_ID` | The RDS Cluster Resource ID |
| `POSTGRES_CLUSTER_READER_ENDPOINT` | A read-only endpoint for the cluster, automatically load-balanced across replicas |
| `POSTGRES_CLUSTER_ENGINE_VERSION_ACTUAL` | The running version of the cluster database |
| `POSTGRES_CLUSTER_HOSTED_ZONE_ID`| The Route53 Hosted Zone ID of the endpoint |

### AWS Root Certs
The AWS root certificate is downloaded and accessible via the `rds-combined-ca-bundle.pem` file in root of your app repo/directory.

### App example
Example JavaScript to make a request to the Postgres cluster:

```js
const { Client } = require('pg')

// set up client
const client = new Client({
  host: process.env.PGHOST,
  port: process.env.PGPORT,
  user: process.env.PG_USER,
  password: process.env.PG_PASSWORD,
  database: process.env.PGDATABASE,
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

### Postgres Infrastructure and Cluster Details
Specifically, the following resources will be created:
- AWS Security Group
  - AWS Security Group Rule - Allows access to the cluster's db port: `5432`
- AWS RDS Aurora Postgres
  - Includes a single database (set by the input: `aws_postgres_database_name`. defaults to `root`)

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

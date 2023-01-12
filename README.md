# Docker to AWS VM

GitHub action to deploy any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an AWS VM (EC2) using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker-compose up`.

## Getting Started Intro Video
[![Getting Started - Youtube](https://img.youtube.com/vi/oya5LuHUCXc/0.jpg)](https://www.youtube.com/watch?v=oya5LuHUCXc)


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

For envirnoment variables in your app, you can provide a `repo_env` file in your repo, a `.env` file in GitHub Secrets named `DOT_ENV`, or an AWS Secret. Then hook it up in your `docker-compose.yaml` file like:

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
        uses: bitovi/github-actions-deploy-docker-to-ec2@v0.4.1
        with:
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID_PTO}}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY_PTO}}
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
      uses: bitovi/github-actions-deploy-docker-to-ec2@v0.4.1
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws_session_token: ${{ secrets.AWS_SESSION_TOKEN }}
        aws_default_region: us-east-1
        domain_name: bitovi.com
        sub_domain: app
        tf_state_bucket: my-terraform-state-bucket
        dot_env: ${{ secrets.DOT_ENV }}
        app_port: 3000
        additional_tags: "{\"key1\": \"value1\",\"key2\": \"value2\"}"

```

## Customizing

### Inputs

The following inputs can be used as `step.with` keys

| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout`          | Boolean | Set to `false` if the code is already checked out (Default is `true`) (Optional) |
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region |
| `aws_ami_id` | String | AWS AMI ID. Will default to latest Ubuntu 22.04 server image (HVM). Accepts `ami-####` values |
| `domain_name` | String | Define the root domain name for the application. e.g. bitovi.com' |
| `sub_domain` | String | Define the sub-domain part of the URL. Defaults to `${org}-${repo}-{branch}` |
| `root_domain` | Boolean | Deploy application to root domain. Will create root and www records. Defaults to `false` |
| `cert_arn` | String | Define the certificate ARN to use for the application. **See note ** |
| `create_root_cert` | Boolean | Generates and manage the root cert for the application. **See note **. Defaults to `false` |
| `create_sub_cert` | Boolean | Generates and manage the sub-domain certificate for the application. **See note **. Defaults to `false` |
| `tf_state_bucket` | String | AWS S3 bucket to use for Terraform state. |
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. (Default is `false`). `stack_destroy` must also be `true`|
| `repo_env` | String | `.env` file containing environment variables to be used with the app. Name defaults to `repo_env`. Check **SEnvironment variables** note |
| `dot_env` | String | `.env` file to be used with the app. This is the name of the [Github secret](https://docs.github.com/es/actions/security-guides/encrypted-secrets). Check **SEnvironment variables** note |
| `aws_secret_env` | String | Secret name to pull environment variables from AWS Secret Manager. Check **SEnvironment variables** note |
| `app_port` | String | port to expose for the app |
| `lb_port` | String | Load balancer listening port. Defaults to 80 if NO FQDN provided, 443 if FQDN provided |
| `lb_healthcheck` | String | Load balancer health check string. Defaults to HTTP:app_port |
| `ec2_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Default is `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}` |
| `ec2_instance_type` | String | The AWS IAM instance type to use. Default is t2.small. See [this list](https://aws.amazon.com/ec2/instance-types/) for reference |
| `stack_destroy` | String | Set to `true` to destroy the stack. Default is `""` - Will delete the elb_logs bucket after the destroy action runs. |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment.  Defaults to `${org}-{repo}-{branch}`.  Use with destroy to destroy specific resources. |
| `app_directory` | String | Relative path for the directory of the app (i.e. where `Dockerfile` and `docker-compose.yaml` files are located). This is the directory that is copied to the EC2 instance. Default is the root of the repo. |
| `additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to all provisioned resources.|

## Note about resource identifiers

Most resources will contain the tag GITHUB_ORG-GITHUB_REPO-GITHUB_BRANCH, some of them, even the resource name after. 
We limit this to a 60 characters string because some AWS resources have a length limit and short it if needed.

We use the kubernetes style for this. For example, kubernetes -> k(# of characters)s -> k8s. And so you might see some compressions are made.

For some specific resources, we have a 32 characters limit. If the identifier length exceeds this number after compression, we remove the middle part and replace it for a hash made up from the string itself. 

### S3 buckets naming

Buckets names can be made of up to 63 characters. If the length allows us to add -tf-state, we will do so. If not, a simple -tf will be added.

## CERTIFICATES - Only for AWS Managed domains with Route53

As a default, the application will be deployed and the ELB public URL will be displayed.

If `domain_name` is defined, we will look up for a certificate with the name of that domain (eg. `example.com`). We expect that certificate to contain both `example.com` and `*.example.com`
Setting `create_root_cert` to `true`will create this certificate with both `example.com` and `*.example.com` for you, and validate them. (DNS validation.)
Setting `create_sub_cert` to `true` will create a certificate just for the subdomain, and validate it.
**Keep in mind that managed domains will be destroyed if stack_destroy is set.**

## Made with BitOps
[BitOps](https://bitops.sh) allows you to define Infrastructure-as-Code for multiple tools in a central place.  This action uses a BitOps [Operations Repository](https://bitops.sh/operations-repo-structure/) to set up the necessary Terraform and Ansible to create infrastructure and deploy to it.

## Contributing
We would love for you to contribute to [bitovi/github-actions-deploy-docker-to-ec2](https://github.com/bitovi/github-actions-deploy-docker-to-ec2).   [Issues](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/issues) and [Pull Requests](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/pulls) are welcome!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-docker-to-ec2/blob/main/LICENSE).

## Provided by Bitovi
[Bitovi](https://www.bitovi.com/) is a proud supporter of Open Source software.


## Need help?
Bitovi has consultants that can help.  Drop into [Bitovi's Community Slack](https://www.bitovi.com/community/slack), and talk to us in the `#devops` channel!

Need DevOps Consulting Services?  Head over to https://www.bitovi.com/devops-consulting, and book a free consultation.

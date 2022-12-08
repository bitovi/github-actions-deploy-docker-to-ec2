# Docker to AWS VM

GitHub action to deploy any [Docker](https://www.bitovi.com/academy/learn-docker.html)-based app to an AWS VM (EC2) using Docker and Docker Compose.

The action will copy this repo to the VM and then run `docker-compose up`.

## Requirements
Your app needs a `Dockerfile` and a `docker-compose.yaml` file.

> For more details on setting up Docker and Docker Compose, check out Bitovi's Academy Course: [Learn Docker](https://www.bitovi.com/academy/learn-docker.html)

For envirnoment variables in your app, provide a `.env` file in GitHub Secrets named `DOT_ENV` and hook it up in your `docker-compose.yaml` file like:
```
version: '3.9'
services:
  app:
    env_file: .env
```

## Example usage

Create `.github/workflow/deploy.yaml` with the following to build on push.

```yaml
on:
  push:
    branches:
      - "main"

permissions:
  contents: read
  # id-token: write

jobs:
  deploy:
    # environment:
    #   name: github-pages
    #   url: ${{ steps.build-publish.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
    - id: deploy
      uses: bitovi/github-actions-deploy-docker-to-ec2@v0.2.0
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID}}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY}}
        aws_session_token: ${{ secrets.AWS_SESSION_TOKEN}}
        aws_default_region: us-east-1
        domain_name: bitovi.com
        sub_domain: app
        tf_state_bucket: my-terraform-state-bucket
        dot_env: ${{ secrets.DOT_ENV }}
        app_port: 3000

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
| `domain_name` | String | Define the root domain name for the application. e.g. bitovi.com' |
| `sub_domain` | String | Define the sub-domain part of the URL. Defaults to `${org}-${repo}-{branch}` |
| `tf_state_bucket` | String | AWS S3 bucket to use for Terraform state |
| `dot_env` | String | `.env` file to be used with the app |
| `app_port` | String | port to expose for the app |
| `lb_port` | String | Load balancer listening port. Defaults to 80 if NO FQDN provided, 443 if FQDN provided |
| `lb_healthcheck` | String | Load balancer health check string. Defaults to HTTP:app_port |
| `ec2_instance_profile` | String | The AWS IAM instance profile to use for the EC2 instance. Default is `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}` |
| `ec2_instance_public_ip` | Boolean | Adds a public IP to the EC2 instance. Defaults to `false`. (App is exposed through an ELB) |
| `stack_destroy` | String | Set to `true` to destroy the stack. Default is `""` |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment.  Defaults to `${org}-{repo}-{branch}`.  Use with destroy to destroy specific resources. |
| `app_directory` | String | Relative path for the directory of the app (i.e. where `Dockerfile` and `docker-compose.yaml` files are located). This is the directory that is copied to the EC2 instance.  Default is the root of the repo. |

## Note about resource identifiers

Most resources will contain the tag GITHUB_ORG-GITHUB_REPO-GITHUB_BRANCH, some of them, even the resource name after. 
We limit this to a 60 characters string because some AWS resources have a length limit and short it if needed.

We use the kubernetes style for this. For example, kubernetes -> k(# of characters)s -> k8s. And so you might see some compressions are made.

For some specific resources, we have a 32 characters limit. If the identifier length exceeds this number after compression, we remove the middle part and replace it for a hash made up from the string itself. 

### S3 buckets naming

Buckets name can be made of up to 63 characters. If the length allows us to add -tf-state, we will do so. If not, a simple -tf will be added.

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

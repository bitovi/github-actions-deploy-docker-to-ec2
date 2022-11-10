# Node App to AWS VM

GitHub action to deploy a Node app to an AWS VM (EC2) using Docker and Docker Compose.

The action will `git clone` this repo from the VM and then run `docker-compose up`.

## Requirements
Your app needs a `Dockerfile` and a `docker-compose.yaml` file.

For envirnoment variables in your app, provide a `.env` file in GitHub Secrets named `DOT_ENV` and hook it up in your `docker-compose.yaml` file like:
```
version: '3.9'
services:
  app:
    env_file: .env
```

## Customizing

### Inputs

The following inputs can be used as `step.with` keys

| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `checkout`          | T/F  | Set to `false` if the code is already checked out (Default is `true`) (Optional) |
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region |
| `tf_state_bucket` | String | AWS S3 bucket to use for Terraform state |
| `dot_env` | String | `.env` file to be used with the app |

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
      uses: bitovi/github-actions-node-app-to-aws-vm@v0.1.0
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID}}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY}}
        aws_session_token: ${{ secrets.AWS_SESSION_TOKEN}}
        aws_default_region: us-east-1
        tf_state_bucket: my-terraform-state-bucket
        dot_env: ${{ secrets.DOT_ENV }}

```


## Contributing
We would love for you to contribute to [`bitovi/github-actions-node-app-to-aws-vm`](hhttps://github.com/bitovi/github-actions-node-app-to-aws-vm).   [Issues](https://github.com/bitovi/github-actions-node-app-to-aws-vm/issues) and [Pull Requests](https://github.com/bitovi/github-actions-node-app-to-aws-vm/pulls) are welcome!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-github-actions-node-app-to-aws-vm/blob/main/LICENSE).

## Provided by Bitovi
[Bitovi](https://www.bitovi.com/) is a proud supporter of Open Source software.
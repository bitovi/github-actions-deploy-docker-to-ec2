# Example ops repo environment for deploying a node app to an ec2 instance

# Setup
(TODO: MORE THOROUGH DOCS)

Modify the following:
1. `example/terraform/terraform.tfvars`
  - all values
2. `example/terraform/provider.tf`
  - `terraform.backend.s3.bucket`
3. `.github/workflows/deploy-example.yaml`
  - `on.push.paths` - all values
  - `jobs.deploy.steps[name=bitops].env.ENVIRONMENT`
  - `jobs.deploy.steps[name=bitops].env.TF_STATE_BUCKET`

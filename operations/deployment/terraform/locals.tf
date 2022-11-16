locals {
  aws_tags = {
    OperationsRepo = "bitovi/github-actions-node-app-to-aws-vm/operations/${var.ops_repo_environment}"
    AWSResourceIdentifier = "${var.aws_resource_identifier}"
    GitHubAction = "bitovi/github-actions-node-app-to-aws-vm"
    OperationsRepoEnvironment = "deployment"
    created_with = "terraform"
  }
}

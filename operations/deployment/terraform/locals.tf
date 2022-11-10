locals {
  aws_tags = {
    OperationsRepo = "${var.app_org_name}-${var.app_repo_name}"
    GitHubAction = "bitovi/github-actions-node-app-to-aws-vm"
    OperationsRepoEnvironment = "deployment"
    created_with = "terraform"
  }
}

locals {
  aws_tags = {
    OperationsRepo            = "bitovi/github-actions-deploy-docker-to-ec2/operations/${var.ops_repo_environment}"
    AWSResourceIdentifier     = "${var.aws_resource_identifier}"
    GitHubOrgName             = "${var.app_org_name}"
    GitHubRepoName            = "${var.app_repo_name}"
    GitHubBranchName          = "${var.app_branch_name}"
    GitHubAction              = "bitovi/github-actions-deploy-docker-to-ec2"
    OperationsRepoEnvironment = "deployment"
    created_with              = "terraform"
  }
}

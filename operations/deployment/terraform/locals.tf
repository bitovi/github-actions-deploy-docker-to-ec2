resource "random_integer" "az_select" {
  min = 0
  max = length(data.aws_ec2_instance_type_offerings.region_azs.locations) - 1

  lifecycle {
    ignore_changes = all
  }
}

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

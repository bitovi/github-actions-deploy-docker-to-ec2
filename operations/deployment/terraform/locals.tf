resource "random_integer" "az_select" {
  min = 0
  max = length(data.aws_ec2_instance_type_offerings.region_azs.locations) - 1

  lifecycle {
    # The AMI ID must refer to an AMI that contains an operating system
    # for the `x86_64` architecture.
    ignore_changes = [all]
  }
}

locals {
  aws_tags = {
    OperationsRepo            = "bitovi/github-actions-node-app-to-aws-vm/operations/${var.ops_repo_environment}"
    AWSResourceIdentifier     = "${var.aws_resource_identifier}"
    GitHubOrgName             = "${var.app_org_name}"
    GitHubRepoName            = "${var.app_repo_name}"
    GitHubBranchName          = "${var.app_branch_name}"
    GitHubAction              = "bitovi/github-actions-node-app-to-aws-vm"
    OperationsRepoEnvironment = "deployment"
    created_with              = "terraform"
  }
}

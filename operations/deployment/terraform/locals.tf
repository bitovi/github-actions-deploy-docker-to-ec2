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
  vpc_id                 = "vpc-081abe910edab4281"
  vpc_cidr               = "172.31.0.0/16"
  subnets                = ["subnet-0f1b65df74adf6e87", "subnet-05d768eabcd7591ea", "subnet-082c8c6a0f81405d3"]
  

}

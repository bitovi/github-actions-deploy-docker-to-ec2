locals {
  aws_tags = {
    OperationsRepo = "jira-qa-metrics-operations"
    OperationsRepoEnvironment = var.ops_repo_environment
    created_with = "terraform"
  }
}

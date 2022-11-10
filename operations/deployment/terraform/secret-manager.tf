data "aws_secretsmanager_secret_version" "environment" {
  secret_id = var.secret_name
}

data "aws_secretsmanager_secret_version" "github_credentials" {
  secret_id = "github_credentials"
}

locals {
  environment = jsondecode(
    data.aws_secretsmanager_secret_version.environment.secret_string
  )
  github_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.github_credentials.secret_string
  )
  git_url_noproto = split("//", var.app_repo_clone_url )

  github_private_link = "https://${local.github_credentials.user}:${local.github_credentials.token}@${local.git_url_noproto[1]}"
}
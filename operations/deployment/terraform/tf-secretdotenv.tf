data "aws_secretsmanager_secret_version" "env_secret" {
  secret_id = "test1-env"
}

locals {
  s3_secret_raw = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.env_secret.secret_string))
  s3_secret_string = join("\n", [for k, v in local.s3_secret_raw : "${k}=\"${v}\""])
}

resource "local_file" "tf-secretdotenv" {
  filename = format("%s/%s", abspath(path.root), "tf-secret.env")
  content = "${local.s3_secret_string}\n"
}
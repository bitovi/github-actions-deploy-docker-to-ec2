terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
#    cloudflare = {
#      source = "cloudflare/cloudflare"
#      version = "~> 3.0"
#    }

  }
  backend "s3" {
    region  = "us-east-1"
    bucket  = "bitovi-jira-integrations-operations-jira-qa-metrics"
    key     = "tf-state"
    encrypt = true #AES-256encryption
  }
}
 
data "aws_region" "current" {}

#provider "cloudflare" {
#  api_token = var.api_token
#}


provider "aws" {
  region = "us-east-1"
  profile = "default"
  default_tags {
    tags = local.aws_tags
  }
}

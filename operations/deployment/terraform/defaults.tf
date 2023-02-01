data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  vpc_id = data.aws_vpc.default.id
}

# us-east-1 contains all AZs, no check is required.
locals {
  zone_b =  tolist([ "us-east-2", "us-west-1", "us-west-2", "ca-central-1"])
  zone_c = tolist([ "us-east-2", "us-west-2"])
  zone_d = tolist([ "us-west-2", "ca-central-1"])
  zone_e = tolist([ "us-east-1" ])
  zone_f = tolist([ "us-east-1" ])
}
data "aws_subnet" "defaulta" {
  availability_zone = "${data.aws_region.current.name}a"
  default_for_az = true
}
data "aws_subnet" "defaultb" {
  count = contains(local.zone_b, "${data.aws_region.current.name}") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}b"
  default_for_az = true
}
data "aws_subnet" "defaultc" {
  count = contains(local.zone_c, "${data.aws_region.current.name}") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}c"
  default_for_az = true
}
data "aws_subnet" "defaultd" {
  count = contains(local.zone_d, "${data.aws_region.current.name}") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}d"
  default_for_az = true
}
data "aws_subnet" "defaulte" {
  count = contains(local.zone_e, "${data.aws_region.current.name}") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}e"
  default_for_az = true
}
data "aws_subnet" "defaultf" {
  count = contains(local.zone_f, "${data.aws_region.current.name}") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}f"
  default_for_az = true
}
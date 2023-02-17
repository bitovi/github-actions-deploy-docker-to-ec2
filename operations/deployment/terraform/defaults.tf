data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"

    # todo: support a specified vpc id
    # values = [var.vpc_id ? var.vpc_id : data.aws_vpc.default.id]
    values = [data.aws_vpc.default.id]
  }
}

output "aws_default_subnet_ids" {
  description = "The subnet ids from the default vpc"
  value       = data.aws_subnets.vpc_subnets.ids
}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "all" {}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# All regions have "a", skipping az validation
data "aws_subnet" "defaulta" {
  availability_zone = "${data.aws_region.current.name}a"
  default_for_az    = true
}
data "aws_subnet" "defaultb" {
  count             = contains(data.aws_availability_zones.all.names, "${data.aws_region.current.name}b") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}b"
  default_for_az    = true
}
data "aws_subnet" "defaultc" {
  count             = contains(data.aws_availability_zones.all.names, "${data.aws_region.current.name}c") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}c"
  default_for_az    = true
}
data "aws_subnet" "defaultd" {
  count             = contains(data.aws_availability_zones.all.names, "${data.aws_region.current.name}d") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}d"
  default_for_az    = true
}
data "aws_subnet" "defaulte" {
  count             = contains(data.aws_availability_zones.all.names, "${data.aws_region.current.name}e") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}e"
  default_for_az    = true
}
data "aws_subnet" "defaultf" {
  count             = contains(data.aws_availability_zones.all.names, "${data.aws_region.current.name}f") ? 1 : 0
  availability_zone = "${data.aws_region.current.name}f"
  default_for_az    = true
}

locals {
  aws_ec2_instance_type_offerings = sort(data.aws_ec2_instance_type_offerings.region_azs.locations)
  preferred_az = var.availability_zone != null ? var.availability_zone : local.aws_ec2_instance_type_offerings[random_integer.az_select.result]
}

data "aws_ec2_instance_type_offerings" "region_azs" {
  filter {
    name   = "instance-type"
    values = [var.ec2_instance_type]
  }

  location_type = "availability-zone"
}

data "aws_subnet" "selected" {
  count             = contains(data.aws_availability_zones.all.names, local.preferred_az) ? 1 : 0
  availability_zone = local.preferred_az
  default_for_az    = true
}
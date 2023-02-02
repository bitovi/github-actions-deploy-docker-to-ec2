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
  vpc_id = data.aws_vpc.default.id
}

# us-east-1 contains all AZs, no check is required.
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
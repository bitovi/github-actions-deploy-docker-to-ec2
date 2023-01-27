data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
  vpc_id = data.aws_vpc.default.id
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "defaulta" {
  availability_zone = "${data.aws_region.current.name}a"
  default_for_az = true
}
data "aws_subnet" "defaultb" {
  availability_zone = "${data.aws_region.current.name}b"
  default_for_az = true
}
data "aws_subnet" "defaultc" {
  availability_zone = "${data.aws_region.current.name}c"
  default_for_az = true
}
data "aws_subnet" "defaultd" {
  availability_zone = "${data.aws_region.current.name}d"
  default_for_az = true
}
data "aws_subnet" "defaulte" {
  availability_zone = "${data.aws_region.current.name}e"
  default_for_az = true
}
data "aws_subnet" "defaultf" {
  availability_zone = "${data.aws_region.current.name}f"
  default_for_az = true
}
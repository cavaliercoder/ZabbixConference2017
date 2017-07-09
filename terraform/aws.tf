provider "aws" {
  region = "ap-southeast-2"
}

data "aws_region" "current" {
  current = true
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

provider "aws" {
  region = "ap-southeast-2"
}

variable "images" {
  type    = "map"
  default = {
    eu-central-1   = "ami-fa2df395"
    ap-southeast-2 = "ami-34171d57"
  }
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

resource "aws_key_pair" "demo_key" {
  key_name_prefix = "demo-"
  public_key      = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "security_group" {
  name        = "allow_access"
  description = "Allow all inbound SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "zabbix_server" {
  ami             = "${var.images["${data.aws_region.current.name}"]}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.demo_key.key_name}"
  security_groups = ["${aws_security_group.security_group.name}"]
  user_data       = "${file("userdata-zabbix.sh")}"
  tags {
    Name = "ZabbixServer"
  }
}

output "zabbix_server_ip" {
  value = "${aws_instance.zabbix_server.public_ip}"
}
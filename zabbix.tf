provider "aws" {
  region = "eu-central-1"
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
}

resource "aws_instance" "zabbix_server" {
  ami             = "ami-82be18ed"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.demo_key.key_name}"
  security_groups = ["${aws_security_group.security_group.name}"]

  tags {
    Name = "ZabbixServer"
  }
}

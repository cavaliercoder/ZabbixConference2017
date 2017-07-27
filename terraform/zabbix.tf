data "aws_ami" "zabbix_server_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Zabbix-Demo-Server*"]
  }
}

resource "aws_key_pair" "demo_key" {
  key_name_prefix = "demo-"
  public_key      = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_security_group" "security_group" {
  name        = "ZabbixDemoAccess"
  description = "Allow all inbound SSH, HTTP and Zabbix traffic"

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

  ingress {
    from_port = 10050
    to_port   = 10051
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "zabbix_server" {
  ami             = "${data.aws_ami.zabbix_server_ami.id}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.demo_key.key_name}"
  security_groups = ["${aws_security_group.security_group.name}"]

  tags {
    Name = "ZabbixServer"
  }
}

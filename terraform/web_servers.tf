data "aws_ami" "web_server_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["Zabbix-Demo-Web-Server*"]
  }
}

resource "aws_alb" "web_alb" {
  name            = "ZabbixDemoALB"
  internal        = false
  security_groups = ["${aws_security_group.security_group.id}"]
  subnets         = ["${data.aws_subnet_ids.all.ids}"]
}

resource "aws_alb_target_group" "web_group" {
  name                 = "ZabbixDemoWebGroup"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${data.aws_vpc.default.id}"
  deregistration_delay = 0

  health_check {
    interval            = 5
    timeout             = 2
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }
}

resource "aws_alb_listener" "web_listener" {
  load_balancer_arn = "${aws_alb.web_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_group.arn}"
    type             = "forward"
  }
}

resource "aws_launch_configuration" "web_conf" {
  name_prefix     = "ZabbixDemoWebServer-"
  image_id        = "${data.aws_ami.web_server_ami.id}"
  instance_type   = "m3.medium"
  spot_price      = "0.07"
  key_name        = "${aws_key_pair.demo_key.key_name}"
  security_groups = ["${aws_security_group.security_group.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_asg" {
  availability_zones        = ["${data.aws_availability_zones.available.names}"]
  name                      = "ZabbixDemoASG"
  launch_configuration      = "${aws_launch_configuration.web_conf.name}"
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 5
  target_group_arns         = ["${aws_alb_target_group.web_group.arn}"]
  health_check_type         = "ELB"
  health_check_grace_period = 60
  force_delete              = true

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ZabbixDemoWebServer"
    propagate_at_launch = true
  }
}

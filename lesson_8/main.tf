provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "availability" {}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "DefaultVPC"
  }
}

resource "aws_security_group" "security_group" {
  name        = "webserver_sg"
  description = "Security group for my webserver"
  vpc_id      = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dynamic_sg"
  }
}

resource "aws_launch_configuration" "webserver_lc" {
  # name            = "webserver_lc"
  name_prefix     = "webserver_lc"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.security_group.id]
  user_data       = file("server.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_web" {
  name                 = "ASG-${aws_launch_configuration.webserver_lc.name}"
  min_size             = 1
  max_size             = 2
  desired_capacity     = 2
  min_elb_capacity     = 2
  launch_configuration = aws_launch_configuration.webserver_lc.name
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.webserver_elb.name]

  dynamic "tag" {
    for_each = {
      Name   = "webserver with asg"
      Owner  = "Const"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "webserver_elb" {
  name               = "webserver-elb"
  availability_zones = [data.aws_availability_zones.availability.names[0], data.aws_availability_zones.availability.names[1]]
  security_groups    = [aws_security_group.security_group.id]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  tags = {
    Name = "webserver_elb"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.availability.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.availability.names[1]
}

output "web_lb_url" {
  value = aws_elb.webserver_elb.dns_name
}

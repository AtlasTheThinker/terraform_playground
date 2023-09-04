provider "aws" {}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Webserver Security Group"
  description = "Security group for my webserver"
  vpc_id      = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "1541", "9092"]
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

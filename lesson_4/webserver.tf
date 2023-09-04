provider "aws" {}

resource "aws_default_vpc" "default" {}

resource "aws_eip" "static_ip" {
  instance = aws_instance.my_webserver.id
}

resource "aws_instance" "my_webserver" {
  ami                    = "ami-0766f68f0b06ab145"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = templatefile("server.sh.tpl", { f_name = "ASD", l_name = "WASF" })

  tags = {
    Owner = "Const"
  }

  lifecycle {
    create_before_destroy = true
  }

  user_data_replace_on_change = true
}


resource "aws_security_group" "my_webserver" {
  name        = "Dynamic Webserver Security Group"
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

output "webserver_instance_id" {
  value = aws_instance.my_webserver.id
}

output "webserver_public_ip" {
  value = aws_eip.static_ip.public_ip
}
provider "aws" {}

resource "aws_instance" "my_webserver" {
  ami                    = "ami-0766f68f0b06ab145"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id]
  user_data              = templatefile("server.sh.tpl", { f_name = "Михаил", l_name = "Зубенко" })
}

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "my_webserver" {
  name        = "Webserver Security Group"
  description = "Security group for my webserver"
  vpc_id      = aws_default_vpc.default.id

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

  tags = {
    Name = "allow_tls"
  }
}

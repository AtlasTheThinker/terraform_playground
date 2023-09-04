provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

output "ami_instance" {
  value = data.aws_ami.ubuntu.id
}

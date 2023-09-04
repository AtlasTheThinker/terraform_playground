provider "aws" {}

resource "aws_instance" "tf_instance_ubuntu" {
  ami           = "ami-0766f68f0b06ab145"
  instance_type = "t2.micro"
}

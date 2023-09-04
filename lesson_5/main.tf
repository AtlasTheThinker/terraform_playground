provider "aws" {

}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "prod"
    }
}

data "aws_vpc" "prod_vpc" {
    depends_on = [ aws_vpc.main_vpc ]
    tags = {
        Name = "prod"
    }
}

output "aws_vpc_id" {
    value = data.aws_vpc.prod_vpc.id
}

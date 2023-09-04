provider "aws" {

}

data "aws_availability_zones" "working" {

}

output "aws_azs" {
  value = data.aws_availability_zones.working.names
}

// Variables
variable "namespace" {
  type = string
}

// VPC
data "aws_availability_zones" "available" {}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.namespace}-vpc"
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  public_subnets = [
    "10.0.101.0/24"]
  tags = {
    name = "${var.namespace}-vpc"
  }
}
output "vpc_output" {
  value = module.vpc
}

//// PUB ssh, publica :80 IN frontend OUT *
//resource "aws_security_group" "PUB" {
//  name = ""
//
//}
//output "sg_PUB" {
//  value = aws_security_group.PUB.id
//}
//
//// PRIV ssh, privada :8080 IN backend OUT frontend
//output "sg_PRIV" {
//  value = aws_security_group.PRIV.id
//}
//
//// PRIV_DB ssh, privada :27017 IN mongodb OUT backend
//output "sg_PRIV_DB" {
//  value = aws_security_group.PRIV_DB.id
//}



// Variables
variable "namespace" {
  type = string
}

// VPC

output "vpc_output" {
  value = module.vpc
}
output "vpc_id" {
  value = module.vpc.default_vpc_id
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



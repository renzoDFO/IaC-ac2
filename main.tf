terraform {
  backend "s3" {
    bucket = "terraform-ac2"
    key = "states/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

// Providers
provider "aws" {
  profile = "default"
  # $HOME/.aws/credentials
  region = "us-east-1"
}

// Variables
variable "namespace" {
  description = "namespace para naming"
  default = "test"
  type = string
}


// Setup
data "aws_availability_zones" "available" {}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "${var.namespace}-vpc"
  cidr = "10.0.0.0/16"
  azs = data.aws_availability_zones.available.names
  public_subnets = [
    "10.0.101.0/24"]
  private_subnets = [
    "10.0.1.0/24"]
  tags = {
    name = "${var.namespace}-vpc"
  }
}
module "ssh_key_gen" {
  source = "./modules/ssh_key"
  namespace = var.namespace
}

locals {
  private_key_name = module.ssh_key_gen.key_name
}
// Deployments
module "frontend" {
  source = "./modules/frontend"
  namespace = var.namespace
  vpc = module.vpc
  private_key_name = local.private_key_name
}
//module "database" {
//  depends_on = [module.networking]
//  vpc = module.networking.vpc_output
//  source = ""
//}
module "backend" {
  source = "./modules/backend"
  namespace = var.namespace
  vpc = module.vpc
  frontend_security_group_name = module.frontend.security_group_id
  private_key_name = local.private_key_name
}

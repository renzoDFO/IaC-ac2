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
  backend_ip = module.backend.public_ip
}
module "database" {
  source = "./modules/database"
  namespace = var.namespace
  vpc = module.vpc
  private_key_name = local.private_key_name
}
module "backend" {
  source = "./modules/backend"
  namespace = var.namespace
  vpc = module.vpc
  frontend_security_group_name = module.frontend.security_group_id
  private_key_name = local.private_key_name
}

// Outputs
output "public_connection_string" {
  description = "Copy/Paste/Enter - SSH Backend"
  value = "ssh -i ${local.private_key_name}.pem ec2-user@${module.backend.public_ip}"
}
output "frontend_connection_string" {
  description = "Copy/Paste/Enter - Desde Backend"
  value = "ssh -i ${local.private_key_name}.pem ec2-user@${module.frontend.private_ip}"
}
output "database_connection_string" {
  description = "Copy/Paste/Enter - Desde backend"
  value = "ssh -i ${local.private_key_name}.pem ec2-user@${module.frontend.private_ip}"
}
output "OUTPUT_IP" {
  value = templatefile("${path.root}/Output_File.yaml", {
    BACKEND_PUBLIC_IP = module.backend.public_ip
    FRONTEND_PUBLIC_IP = module.frontend.public_ip
    DATABASE_PUBLIC_IP = module.database.public_ip
    BACKEND_PRIVATE_IP = module.backend.private_ip
    FRONTEND_PRIVATE_IP = module.frontend.private_ip
    DATABASE_PRIVATE_IP = module.database.private_ip
  })
}
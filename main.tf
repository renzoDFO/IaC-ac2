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

module "networking" {
  source = "./modules/networking"
  namespace = var.namespace
}
module "ssh" {
  source = "./modules/ssh_key"
  namespace = var.namespace
}
//module "database" {
//  depends_on = [module.networking]
//  vpc = module.networking.vpc_output
//  source = ""
//}
//module "backend" {
//  depends_on = [module.database]
//  vpc = module.networking.vpc_output
//  security_group_id = module.networking.sg_PRIV
//  source = "./modules/backend"
//}
//module "frontend" {
//  depends_on = [module.backend]
//  vpc = module.networking.vpc_output
//  source = ""
//}
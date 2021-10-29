terraform {
  backend "s3" {
    bucket = "terraform-ac2"
    key    = "states/terraform.tfstate"
    region = "us-east-1"
  }
}
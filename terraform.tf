provider "aws" {}

terraform {
  backend "s3" {
    bucket = "jenkins201-tfremotestatenic"
    key    = "terraform-iac"
    region = "eu-west-1"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "172.18.0.0/16"
}

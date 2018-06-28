provider "aws" {}

resource "aws_vpc" "main" {
  cidr_block = "172.18.0.0/16"
}

output "main_vpc_id" {
  value = "${aws_vpc.main.id}"
}

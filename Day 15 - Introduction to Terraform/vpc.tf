resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "name" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}
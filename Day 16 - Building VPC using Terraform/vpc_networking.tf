# Query/List all the AWS Availability Zones for a given region, configured in the provider
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC creation
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Create Private Route Table
resource "aws_default_route_table" "private_route" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name = "Private Route Table"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = 2
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id 
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count                   = 2
  cidr_block              = var.private_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id 

  tags = {
    Name = "Private Subnet"
  }
}

# Create Route Table Association - Public
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
  route_table_id = aws_route_table.public_route.id
  depends_on     = [aws_route_table.public_route, aws_subnet.public_subnets]
}

# Create Route Table Association - Private
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
  route_table_id = aws_default_route_table.private_route.id
  depends_on     = [aws_default_route_table.private_route, aws_subnet.private_subnets]
}

# Create security group
resource "aws_security_group" "security_group" {
  name        = "Allow SSH"
  description = "Allow ssh on port 22"
  vpc_id      = aws_vpc.main.id 

  tags = {
    Name = "Security Group SSH"
  }
}

# Security group rules - Inbound
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group rules - Outbound
resource "aws_security_group_rule" "ssh_outbound_access" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
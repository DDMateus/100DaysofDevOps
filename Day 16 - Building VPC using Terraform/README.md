### Day 16 - Building VPC using Terraform

#### What is VPC?
<p align="justify">A Virtual Private Cloud (VPC) is a logical portion of the cloud that is isolated and customizable, allowing you to define your network for building infrastructure in the cloud.</p>

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/8263402c-8652-4fc4-afa2-713f2d606a5f)

#### Default Components of a VPC:
- **Network Access Control List (NACL):** Acts as a firewall, controlling the traffic allowed to flow in and out of a subnet.
- **Security Group:** Acts as a virtual firewall for controlling traffic to and from instances, allowing outbound traffic by default and denying inbound traffic unless explicitly allowed.
- **Route Table:** Handles internal routing within the VPC.

#### Required Configurations for VPC:
- **Internet Gateway:** Facilitates communication between instances within the VPC and the internet.
- **Subnets:** Divides the VPC into multiple subnetworks to organize resources and control access.
- **Custom Route Table (public):** Routes traffic to the internet gateway for public subnets.

#### Terraform Code:
```hcl
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
```

#### Variables:
```hcl
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
```

Terraform Apply.
![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/8096c3b2-be6b-43a6-bef1-72c2a4a6739b)

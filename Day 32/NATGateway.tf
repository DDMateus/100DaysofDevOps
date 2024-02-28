# Retrieve Public Subnet
data "aws_subnet" "public_subnet" {
    filter {
      name   = "tag:Name"
      values = ["Public Subnet"]
    }   
}

# Retrieve Private Route Table
data "aws_route_table" "private_route_table" {
    filter {
      name   = "tag:Name"
      values = ["Private Route table"]
    } 
}

# Create EIP for NAT Gateway
resource "aws_eip" "elastic_ip" {
    domain = "vpc"
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.elastic_ip.id
    subnet_id     = data.aws_subnet.public_subnet.id

    tags = {
      Name = "NAT Gateway"
    }
}

# Add route to NAT Gateway
resource "aws_route" "nat_gateway_route" {
    route_table_id         = data.aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
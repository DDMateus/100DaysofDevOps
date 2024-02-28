# Day 32 - Introduction to NAT Gateway

## Overview

<p align="justify">A NAT Gateway in AWS enables instances and other AWS services in private subnets to connect to the internet while preventing direct incoming connections initiated from the internet to those resources.</p>

## How does it work?

<p align="justify">We attach an Elastic IP address (EIP) to a NAT gateway, which is then connected to the internet through the internet gateway. This setup allows instances in a private subnet to access the internet through the NAT gateway.</p> 
<p align="justify">The NAT gateway routes traffic from the instances to the internet gateway and routes internet responses back to the instances.</p>

<p align="justify">NAT Gateway maps multiple private IP addresses to a single public IPv4 address.</p>

## AWS Management Console

### Create NAT Gateway:

1. Visit the VPC console > NAT Gateways > Create NAT Gateways.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/c0f4a6f1-bda5-44f9-b66a-a77a7ab7d624)

2. Add the NAT Gateway to a public subnet in your VPC and allocate an EIP.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/bec63524-eaca-4653-bc0e-4f61a33dd888)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/a480b9e4-5280-4955-9106-6abed0a5fe75)

3. Once the NAT gateway is available, add it to your default route table. Configure the route table associated with your private subnets to include a route entry that directs internet traffic to the NAT Gateway.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/c2779ca2-3f79-4e41-8e1b-652181403a21)

NAT Gateway must be available per availability zone to ensure high availability and fault tolerance and is fully managed by AWS.

## Limitations

- <p align="justify">It's only possible to associate one EIP with a NAT Gateway, and the EIP cannot be dissociated from the NAT Gateway after creation unless you delete it. To use a different EIP for your NAT Gateway, you need to create a new one with the required address, update route tables, and then delete the existing NAT Gateway if it's no longer required.</p>
- <p align="justify">Security groups cannot be associated with a NAT Gateway, they can only be associated with instances within private subnets to control traffic.</p>
- <p align="justify">Network ACLs can be used to control traffic to and from the subnet in which the NAT gateway is located.</p>

## Terraform

```hcl
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
```

This Terraform script demonstrates how to create and configure a NAT Gateway along with its associated resources.

# Day 15 - Introduction to Terraform

<p align="justify">Terraform is a powerful tool used for provisioning infrastructure across multiple cloud providers, such as AWS, Google Cloud, Azure, and others. In this project, we'll focus on learning about Terraform with the AWS provider.</p>

## Prerequisites
Before diving into Terraform, make sure you have the following:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/8295a4ab-8494-4704-b3e6-dba158a171e1)

1. **AWS Account**: You need an AWS account to create and manage resources.
2. **IAM User**: Set up an IAM user with appropriate permissions for Terraform.
3. **AWS Credentials**: Obtain AWS Access Key and Secret Key for your IAM user.

You can configure your AWS CLI with your credentials using the following command:
```powershell
aws configure
```

## Terraform Language Basics
Terraform uses HashiCorp Configuration Language (HCL) for defining infrastructure. Key points to remember:

- Files end with the extension `.tf`.
- HCL is declarative, meaning we define what we want, and Terraform figures out how to create it.

## Building an EC2 Instance
For our project, we'll build an EC2 instance. Here's what we need:

- **Amazon Machine Image (AMI)**: We'll use the AmazonLinux AMI.
- **Instance Type**: We'll use `t2.micro`.
- **Network Information (VPC/Subnet)**: We'll use the default VPC.
- **Tags**: Labels to categorize AWS resources.
- **Security Groups**: Virtual firewalls to control traffic.
- **Key Pair**: Used for SSH access to the EC2 instance.

## Key Pair:
```hcl
resource "aws_key_pair" "key_pair" {
  key_name   = "Key_Pair_EC2"
  public_key = "<public key>"
}
```

## Security Groups:
```hcl
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group SSH"
  }
}
```

## EC2 instance:
```hcl
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0d7a109bf30624c99"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = aws_key_pair.key_pair.id
  subnet_id              = aws_subnet.name.id
  
  tags = {
    Name = "EC2 Instance"
  }
}
```

## Provider:

<p align="justify">This tells terraform that we are going to use AWS as a provider and want to deploy our infrastructure in us-east-1 region.</p>

  ```hcl
provider "aws" {
  region = "us-east-1"
}
```

## Getting Started
To begin building your infrastructure with Terraform:

1. Initialize the directory:
   ```powershell
   terraform init
   ```

2. Plan your changes:
   ```powershell
   terraform plan
   ```

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/24e9d0c4-a9a5-46d7-aa1d-7ca3b2859de4)

3. Apply your changes:
   ```powershell
   terraform apply
   ```
<p align="justify">This command will apply all the changes, it will read the code and translate it to API calls to the Provider (aws).</p>

Result:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/410e59eb-87e6-43c1-aacc-d988573aafdc)

## Updating Resources
To update existing resources, simply modify the desired configuration in your `.tf` files and re-run `terraform plan` and `terraform apply` commands.

```hcl
tags = {
    Name = "EC2"
  }
```

Terraform plan:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/4fd5f3db-59d4-4f8b-b4cd-2c590ca8c741)

<p align="justify">Terraform keeps track of all the resources it has already created in .tfstate files, so it is already aware of the resources that already exist.</p>

Changes applied:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/3a7a8c5b-ff87-4085-a4ee-fdc13fd168fc)

## Cleaning Up
To clean up resources created by Terraform, you can use:
```powershell
terraform destroy
```

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/50c53313-5c7a-45e2-b849-c1943d56aa5e)

# Day 11 - Restricting S3 Bucket Access to Specific IP Addresses

## Problem:
- Need to restrict access to an S3 bucket to specific IP addresses for Get/Put operations.

## Solution:
- Utilize S3 Bucket policies written in JSON to control access to objects stored in the bucket.

### AWS Management Console:
1. **Create an S3 Bucket**:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2a9f0d0c-346c-42fd-b94d-368cbeac78a4)

2. **Configure Bucket Policy**:
   - Go to the bucket's permissions tab and select "Bucket Policy".
   - Click on "Policy generator" to create a new policy.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/9f5e9ea4-2fc5-44df-ad2b-f52fcbc47620)

   - Add a statement specifying the allowed actions, resources, and conditions (e.g., IP address).
 
![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/7dfbff51-8625-42f0-a99e-ac047c5d5ba9)

   - Generate the policy.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/8749cd9b-0d42-4308-a6d2-14023c1c8201)
  
   - Review and save the policy.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/45872036-aab0-420d-9d63-5a7d3a82c7f7)

4. **Test**:
   - Upload an image or file to the bucket.

 ![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/501c030d-9b51-48b0-888a-3a9955f15059)

### AWS CLI:
- Create an S3 Bucket using the AWS CLI.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/eac95934-7abe-4d01-9115-469b579bd550)

- Attach a bucket policy using the following JSON policy:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/31c7077d-bd19-4e9d-98b3-c83bb53f1c19)

```json
{
    "Version": "2012-10-17",
    "Id": "Policy1710532489776",
    "Statement": [
        {
            "Sid": "Stmt1710532406508",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::mys3buckettest99/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "<your IP>"
                }
            }
        }
    ]
}
```

### Result:
- Test the policy by updating an image or file in the bucket and ensure that access is restricted based on the specified IP address.

### Terraform:
```hcl
provider "aws" {
  region = "us-east-1"
}

# Create an S3 Bucket 
resource "aws_s3_bucket" "example" {
  bucket = "s3-bucket-terraform99"
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "allow_access_from_specific_ip" {
  bucket = aws_s3_bucket.example.bucket
  policy = <<Policy
  {
    "Version": "2012-10-17",
    "Id": "Policy1710532489776",
    "Statement": [
        {
            "Sid": "Stmt1710532406508",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "${aws_s3_bucket.example.arn}/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": "<your IP>"
                }
            }
        }
    ]
}
Policy
}
```

# Day 10 - Restricting User to Launch only T2 Instances

## Problem:
- Limit users to only launch T2 instance series, which are cheaper than other instance types.

## Solution: 
- IAM Managed Policy

### Scenario 1: AWS Management Console

1. Navigate to IAM console > Policies > Create policy.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/ed4dc8e8-c880-4f4b-af59-1efa69f6a82f)

2. Give full access to EC2 and in Request conditions, select “Add request condition”. This is where we are going to specify that the user can only launch T2 instance types.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2d131c55-75a4-4b61-b486-ce8111717b0a)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/b7b4105f-afc9-4cd1-ae7a-b8dff06c22dc)

   - This provides a condition expression within the context of AWS IAM.
     - `ec2:InstanceType`: Refers to the Amazon EC2 service and specifically to the instance type.
     - `(If exists, StringLike t2.*)`: Condition that applies to the EC2 instance type.
       - If exists – Checks if the attribute “ec2:InstanceType” exists.
       - StringLike – Condition operator that the attribute value should be compared using a string pattern.
       - t2.* - String pattern being checked against.
3. Give the policy a name.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/aaf40d40-2041-412d-b396-87c8f5344fe2)

4. Attach this policy to the user you want to test.
   - Go to the user.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/87f97f68-fbe3-4071-9c7e-8e27e6b2f220)

   - Click on “Add permissions”.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/1137a5ff-8b60-4a29-bdac-a913d4163fcd)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/6980902c-c722-45d9-8abb-9173fa24bd4a)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/596b084f-d9cc-444e-b8a4-19470e058607)

6. Logout and log in as that particular user and try to launch an EC2 instance type as t2.micro.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2c37fbf3-c0bf-4946-9e02-752e3fb6eba6)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/fcdfd965-1146-416d-bed7-28a8447a87c4)

7. Now, try to launch some other instance type.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/554863ff-3b73-4bec-a955-7c6fe11d4fa5)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/1104aeca-b627-40dd-89ef-cc8f66788c0e)

8. To decode this message, use AWS CLI.

The command `aws sts decode-authorization-message` is used to decode an encoded authorization message returned by AWS when an IAM policy denies access to a request. This command will help us understand the reason behind the denial.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/b815bfe8-8bf6-498b-885d-72326b238fb0)

   The decoded message indicates that the request to run EC2 instances “RunInstances” was denied for the principal named “Test-ec2-policy” (`arn:aws:iam::<AWS account>:user/Test-ec2-policy`).
   - Allowed: The request was denied (false).
   - ExplicitDeny: No explicit deny was applied (false).
   - MatchedStatements: No matching IAM policy statements were found.
   - Failures: No failures were reported.
   
   The context of the denial:
   - Action: The action attempted was RunInstances.
   - Resource: The resource targeted was instances in the us-east-1 region (`arn:aws:ec2:us-east-1:<AWS account>:instance/*`).
   - Conditions: Several conditions were checked, including the instance type (t3.micro), instance tenancy (default), region (us-east-1), and others.

### Scenario 2: AWS CLI

1. Create a file named `ec2policy` and copy the policy created above to it.
2. Run the following command in the terminal:
   ```powershell
   aws iam create-policy --policy-name my-t2-restriction-policy --policy-document  file://ec2policy.json
   ```
![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/64b52795-6c61-4a9b-a118-42217d1b81c6)

   - This command will create an IAM policy named “my-t2-restriction-policy” with the policy document provided in the file `ec2policy`.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/562d1296-b127-417b-8ae3-0eff19481d23)

3. Attach this policy to a particular user.
   ```powershell
   aws iam attach-user-policy --policy-arn arn:aws:iam::XXXXX:policy/my-t2-restriction-policy --user-name <IAM user>
   ```
![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2aa53049-ed94-488f-b69b-727a30618c11)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/942c20ae-05d2-4009-87c5-4392e941005f)

### Scenario 3: Terraform

```hcl
resource "aws_iam_user" "user" {
  name = "Test-User"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:GetResourcePolicy",
        "ec2:GetDefaultCreditSpecification",
        ...
        "ec2:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringLikeIfExists": {
          "ec2:InstanceType": "t2.*"
        }
      }
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "*",
      "Condition": {
        "StringLikeIfExists": {
          "ec2:InstanceType": "t2.*"
        }
      }
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::<AWS account>:role/*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.policy.arn
}

```

- IAM user created.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/8c48634b-48c4-4347-bb22-fea988d5eae4)

- IAM policy created.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/15ad6a7b-2082-40c0-b46b-a76665936296)

- Policy attached.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/4df54a6a-38c7-45aa-9843-f7c4b0d91999)

#### What if I wanted to attach a new policy to an existing IAM user (Test-ec2-policy)?

```hcl
data "aws_iam_user" "example" {
  user_name = "Test-ec2-policy"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:GetResourcePolicy",
        ...
        "ec2:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringLikeIfExists": {
          "ec2:InstanceType": "t2.*"
        }
      }
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "ec2:RunInstances",
      "Resource": "*",
      "Condition": {
        "StringLikeIfExists": {
          "ec2:InstanceType": "t2.*"
        }
      }
    },
    {
      "Sid": "VisualEditor2",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::<AWS account>:role/*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = data.aws_iam_user.example.user_name
  policy_arn = aws_iam_policy.policy.arn
}
```

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/6abf36db-d5bd-412d-bfbc-62c4e13f3aef)

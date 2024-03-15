# Day 7 – AWS S3 Event

## Problem
Whenever anyone deletes any object in S3 bucket you will get the notification.

## Solution
- AWS Console
- Terraform

## What is S3 Event?
<p align="justify">Amazon S3 notification features enables you to receive notifications (SNS/SQS/Lambda) when certain events happen in your bucket. S3 events work at the object level, so if something happens, maybe PUT, POST, COPY or DELETE, then the event is generated and that event will be delivered to the target (SNS, SQS or Lambda).</p>

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/1aed0a4b-2da3-4184-b0e9-7788912cf3ab)

## Configure S3 Events: AWS Management Console
1. Create a Topic.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/0f9d298f-bb07-4c82-baa1-98d7d73bd941)

2. Change JSON policy, we need permissions on SNS topic to allow S3 event system to deliver events to it
The JSON represents an IAM policy that allows anyone to publish messages to the specified SNS topic, but only if the request originates from the specified S3 bucket.
```json
{
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-east-1:<AWS account>:S3_Events",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "arn:aws:s3:::s3-events-bucket"
        }
      }
    }
  ]
}
```

3. Create a S3 bucket

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/bad7d8c3-27e4-48f7-8bad-45346144734a)

4. Create an event notification
You will receive a notification on your email everytime an object is delected from the bucket.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/3eedb569-5f77-4481-aaf5-186ceb781b0e)

5. Test 
Try to delete something from the bucket.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/b60d7c1f-00e8-4c04-bc64-50c1baeefc18)

   - Delete it.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/5c6173f3-8bdc-4460-a7e1-54cdc71cb45e)

Email notification:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/120dbbcf-8862-403f-a8ad-97b21cc4f7a1)

## Terraform
```hcl
# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"
}

# Create SNS Topic
resource "aws_sns_topic" "S3Events" {
  name = "s3events"

  policy = <<Policy
  {
  "Version": "2008-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__default_statement_ID",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-east-1:*:s3events",
      "Condition": {
        "StringEquals": {
          "AWS:SourceArn": "${aws_s3_bucket.s3_bucket.arn}"
        }
      }
    }
  ]
}
Policy
}

# Create subcription
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.S3Events.arn}"
  protocol  = "email"
  endpoint  = "<your email>"
}

# Create S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "s3-bucket-unique-12"
  force_destroy = true

  tags = {
    Name        = "S3 Bucket"
  }
}

# Create event notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.s3_bucket.id}"

  topic {
    topic_arn     = "${aws_sns_topic.S3Events.arn}"
    events        = ["s3:ObjectRemoved:*"]
  }
}
```

## Resources created
- **S3 Bucket:** 

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/27dbb15d-3bc1-4359-9dbb-118fc3ca9ba0)

- **SNS Topic:** 

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/bbe6af70-22da-49c9-8502-f93503e7fe0d)

- **Subscription:** [Your email](mailto:<your email>)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/132573ad-5cdf-487c-9270-f01144180143)

Upload something to the bucket and delete it:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/c2341b72-346d-424a-8c81-4215f65fcc20)

- **Email:**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/4bb28b13-4bd8-4646-843f-fe115f890715)

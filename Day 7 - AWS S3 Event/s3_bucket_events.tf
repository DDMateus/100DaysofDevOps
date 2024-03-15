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
  endpoint  = "diogo.22.09@gmail.com"
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
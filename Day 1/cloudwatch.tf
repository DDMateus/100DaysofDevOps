resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = "high-cpu-utilization-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = ["arn:aws:sns:us-east-1:381492302972:CPUAlarm"]
  dimensions                = {
    InstanceId              = "random instance id"
  }
}
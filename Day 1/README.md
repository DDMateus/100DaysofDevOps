# Day 1: Introduction to CloudWatch Metrics

#### Problem:
- Create a CloudWatch alarm that sends an email using SNS notification when CPU Utilization is more than 70%.
- Creating a Status Check Alarm to check System and Instance failure and send an email using SNS notification

#### Solution:
We can achieve this via AWS CLI, AWS Console, CloudFormation, Terraform, and others.

AWS CloudWatch is a service provided by AWS to monitor AWS resources and applications running on AWS.

##### Scenario 1: Creating a CloudWatch alarm for CPU Utilization

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/3fa4daba-d935-48d0-a84c-b7ab24f9cc68)

1. Open CloudWatch console.
2. Choose Alarms, Create Alarms.
3. Select metrics -> EC2 -> Per-Instance-Metric -> CPU -> Utilization -> Select metric.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/d7987c5e-bd92-416f-a43b-e38a3f79fe2b)

Specify that the alarm is triggered if the CPU usage is above 70% for two consecutive sampling periods. Under additional settings, for treat missing data, choose bad (breaching threshold), as missing data points may indicate that the instance is down.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/46f8611c-2b3e-4d9c-a6e9-53d6fe416de0)

Choose In alarm and create a new SNS topic. To create a new SNS topic, choose new list, for send notification to, type a name of SNS topic (for eg: HighCPUUtilizationThreshold) and for Email list type a comma-separated list of email addresses to be notified when the alarm changes to the ALARM state. Each email address is sent to a topic subscription confirmation email. You must confirm the subscription before notifications can be sent.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/ab9da627-bf02-47b1-800f-d64a07f52afc)

4. Create Alarm.

##### Solution 2: Setup CPU usage Alarm using AWS CLI
1. Create an alarm using the put-metric-alarm command.

```shell
aws cloudwatch put-metric-alarm --alarm-name cpu-mon --alarm-description "Alarm when CPU exceeds 70 percent" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 70 --comparison-operator GreaterThanThreshold --dimensions "Name=InstanceId,Value=i-12345678" --evaluation-periods 2 --alarm-actions arn:aws:sns:us-east-1:<your AWS account>:HighCPUUtilizationAlarm --unit Percent
```
In AWS Console:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/eaf8d9cb-a0b0-4a83-be2b-2011a8aaaf54)

2. To test, change the alarm state to ALARM.
```shell
aws cloudwatch set-alarm-state --alarm-name "cpu-mon" --state-reason "initializing" --state-value ALARM
```

In AWS Console:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/0f687f2a-66b9-4e37-b5f5-90bd3239d7a8)

Check your email:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/dc278d8f-3e41-4784-b4c9-b37d26504f8f)

##### Solution 3: Setup CPU usage alarm using Terraform.
- Open a text editor (Visual Studio Code)

##### Scenario 2: Creating a status check alarm

#### Status check can be:
System status check – Monitors AWS system on which our instance runs. It needs AWS help to repair it or we can try to repair it by stopping and starting.

Instance status check – Monitors software and network configuration of individual instances.
  
1. Open EC2 instance console and launch an instance.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/162ffbe3-4ca1-4941-bd3a-cedd8f5efe5f)

2. Select the instance, choose Status Check tab, and choose to Create Status Check Alarm. Create or use an existing SNS notification. Select 2 consecutive periods of 1 Minute.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/1ea71637-ae8f-47ff-b57d-f476cc8cbd32)
![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/afa9d8f8-8652-4435-8bf9-10f935d33c8d)

##### Solution 2: Create a status check alarm via AWS CLI.
1. Run the following command (use your EC2 instance ID and SNS topic arn).
```shell
aws cloudwatch put-metric-alarm --alarm-name StatusCheckFailed-Alarm-for-test-instance --metric-name StatusCheckFailed --namespace AWS/EC2 --statistic Maximum --dimensions Name=InstanceId,Value=<EC2 Instance ID> --unit Count --period 300 --evaluation-periods 2 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --alarm-actions arn:aws:sns:us-east-1:<your AWS account>:HighCPUUtilization
```

In AWS Console:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/f80a00bc-1376-4017-a98d-9878cf62690f)

2. Change the alarm-state from OK to ALARM.
```shell
aws cloudwatch set-alarm-state --alarm-name "StatusCheckFailed-Alarm-for-test-instance" --state-reason "initializing" --state-value ALARM
```
In AWS Console:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/9e91e861-60ac-493e-a705-95a12bc1b4b3)

Email notification:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/82e66802-6df2-4eed-aca1-f75cd267538a)



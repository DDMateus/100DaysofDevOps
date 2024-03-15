# Day 13 - How to Stop/Start EC2 Instance on a Scheduled Basis to Save Costs

## Problem:
- <p align="justify">Shut down all EC2 instances at 6 PM and bring them back the next day at 9 AM (Monday to Friday) to save money.</p>

## Solution:
- Use a Lambda Function in combination with CloudWatch Events.

## Challenges:
- <p align="justify">Developers may need their instances to run beyond regular hours or during weekends for tasks such as urgent patches or working late on projects.</p>
  
<p align="justify">The suggested solution involves manually specifying a list of these instances within the Python code of a Lambda function. However, if an exception occurs during the function's execution, likely due to issues related to instances or tasks, it triggers a change management process. In this process, the problematic instance that is needed for late-night work or weekend tasks must be manually removed from the instance list specified in the code. While not ideal, this solution enables developers to manage their instance requirements effectively despite potential challenges.</p>

**Lambda Function**  <p align="justify">A serverless compute service provided by AWS that allows us to run code without provisioning or managing servers. It enables us to execute code in response to events triggered by various AWS services or HTTP requests via API Gateway. Lambda functions can be written in several programming languages such as Python.</p>

**CloudWatch Events**  <p align="justify">A service provided by AWS that enables monitoring and responding to events. It allows us to define rules to trigger actions, such as running Lambda functions, based on generated events. In our case, CloudWatch Events are used to trigger a Lambda function at a specific time (e.g., 6 PM on weekdays) to automate the shutdown of EC2 instances.</p>

1. **Create IAM Role so that the Lambda function can interact with CloudWatch Events.**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/d9ebad67-9e5c-4347-b315-c57153f4821e)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/a48d56c3-e079-4dfd-abc4-f5b63dc5bea0)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/0b23e836-3aa1-4394-a45e-26628d9c5bcc)

2. **Create IAM Policy**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/e86a6b20-a009-48fa-b6ef-4f8893458cc8)

The IAM policy provides permissions for two different sets of actions:
- <p align="justify">Permissions for AWS CloudWatch Logs: This allows users or roles associated with this policy to create log groups, log streams, and put log events to CloudWatch Logs for all groups across all AWS accounts.</p>
- <p align="justify">Permissions for Amazon EC2: This allows users or roles associated with this policy to start and stop EC2 instances across all AWS accounts.</p>

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/c2b59ed2-bd2d-4c14-97b8-87b2965024c0)

3. **Add this newly created policy to the role.**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2841e050-0648-4271-9ffe-fb162517e7bd)

4. **Create Lambda Function**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/bab4d931-2362-4055-902b-81ac994e7a02)

Create 2 Lambda functions:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/41aa0f54-4faf-4742-b8ac-8473cca7a007)

- Example how to create Lambda functions (Choose Python runtime):

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/6acbb60d-421a-43d6-9888-b3797bf32d03)

<p align="justify">Select the Lambda function created and paste the code to start and stop EC2 instances. In our case, we create two separate Lambda functions, one for starting and the other for stopping EC2 instances.</p>

Stop:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/e3c113ef-4c5d-441d-b6c1-ac043f5c4c65)

Start:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/97fbaa0b-fb1d-4916-b5c7-568cf474c42c)

**Code for Stopping Instances:**
```python
import boto3

region = 'us-east-1'
instances = ['i-0544d201c39ea6c80']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.stop_instances(InstanceIds=instances)
    print('Stopped your instances: ' + str(instances))
```

**Code for Starting Instances:**
```python
import boto3

region = 'us-east-1'
instances = ['i-0544d201c39ea6c80']

def lambda_handler(event, context):
    ec2 = boto3.client('ec2', region_name=region)
    ec2.start_instances(InstanceIds=instances)
    print('Started your instances: ' + str(instances))
```

4. **Create the CloudWatch event to trigger this Lambda function**

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/ece1be78-9316-4490-ad39-199bb9007553)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/12f853de-9069-4862-84aa-5bc88e29cd5f)

To shut down our instances at 6 PM every day:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/da92727d-2609-4f6e-b808-db482232b083)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/cb40bde1-c244-4404-bbc2-e4889c0a013c)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/abf468f2-7c32-4772-8889-4abaa5ca3e98)

Now, do the same to the starting lambda function.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/4faad1b3-f525-4529-8a78-0ddae3c0fef9)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/74c00913-d84b-40f4-a758-d21e2ed9f1ea)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/dd6c6e99-e44c-4dca-809a-40d9e7a5f323)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/4e8e86b5-9289-478d-bb3f-8fa8d0c7b874)


5. **Go to the Lambda console, select your Lambda function, “Monitor” and click “View logs in CloudWatch”.**

In order to do a quick test to our system, I changed the hours in which our Lambda functions should be executed.

14:40 - Start EC2 Instance

14:43 - Stop EC2 Instance

For stopping the instance:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/1a90bd95-4ce7-47ae-b36f-63f083670144)

For starting the instance:

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/c4773e34-25d9-446a-97d5-90f3e2de84d9)

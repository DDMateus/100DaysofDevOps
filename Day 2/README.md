# Introduction to Simple Notification Service (SNS)

## Problem:
- Sending out notifications via Email, SMS, and other mediums when an event occurs.

## Solution can be achieved by:
1. AWS Console
2. AWS CLI
3. Terraform
4. CloudFormation
5. Others

## Overview:
<p align="justify"> Simple Notification Service (SNS) is a web service provided by AWS that enables sending notifications from the cloud to distributed systems or individual endpoints. When a specific event occurs, SNS can be used to send a notification, creating a comprehensive monitoring solution when integrated with services like CloudWatch.</p>

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/6b311997-7ff8-4dc0-91ce-9840e89e55ca)

### Components of SNS:
- **Publisher**: Entity triggering the sending of a message (e.g. CloudWatch Alarm, S3 events). 
- **Topic**: Object to which messages are published. Messages published to a topic are delivered to all subscribers.
- **Subscriber**: Endpoint where messages are sent. 

All messages published to Amazon SNS are stored redundantly across multiple Availability Zones (AZs).

## AWS Console:
1. Open the SNS console and create a new topic.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/0b0179fa-5b9a-4964-abc1-c0bc99895a48)

2. Select "Subscriptions" on the left panel and create a subscription.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/9085be90-6a38-4fc1-9b07-af7a8399a97d)

3. Confirm the subscription via email.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/0eb2d66f-6308-4bbd-984b-bdfb8858b1b0)

4. Publish a message by selecting "Publish message" in Topics.

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/ddd92d17-064e-48ae-851a-af77b1b0a137)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/2359b54f-5bcd-4b49-818a-88ff0accaf83)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/84e7d972-eba5-4ef4-a875-474839577e74)

![image](https://github.com/DDMateus/100DaysofDevOps/assets/88774178/6ed5b012-774f-40a6-9d61-c95636272fba)

## AWS CLI:
1. Create a new topic:
   ```
   aws sns create-topic --name "<your topic>"
   ```
2. Subscribe to the topic:
   ```
   aws sns subscribe --topic-arn arn:aws:sns:us-east-1:<your AWS account>:<your topic> --protocol email --notification-endpoint <your email>
   ```
3. Publish to a Topic:
   ```
   aws sns publish --topic-arn arn:aws:sns:us-east-1:<your AWS account>:<your topic> --message "hello from sns"
   ```
4. List all the subscribers:
   ```
   aws sns list-subscriptions
   ```

## Additional Operations:
- To unsubscribe from a topic:
  ```
  aws sns unsubscribe --subscription-arn arn:aws:sns:us-west-2:<your AWS account>:<your topic>
- Delete a topic:
  ```
  aws sns delete-topic --topic-arn arn:aws:sns:us-west-2:<your AWS account>:<your topic>
  ```
- List topics:
  ```
  aws sns list-topics
  ```

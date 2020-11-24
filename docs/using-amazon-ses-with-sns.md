## Using Amazon SES to send emails and receive bounce/spam reports via SNS

Sharetribe can be configured to send emails via SMTP. The core team is currently using Amazon SES as mail service.

### Setup mail sending with SES

Get the account credetentials and details using your Amazon account and SES UI. Then fill in the following config variables:

```
mail_delivery_method:              smtp
smtp_email_domain:                 [the domain part of the sender address you are using]
smtp_email_address:                [get the value from AWS/SES config]
smtp_email_user_name:              [get the value from AWS/SES config]
smtp_email_password:               [get the value from AWS/SES config]
smtp_email_port:                   [get the value from AWS/SES config]
```

### Setup SNS notifications for bounces and spam complaints

Sharetribe can react to incoming bounce and spam reports and disable sending non-transactional emails to those addresses.
This means that newsletter type emails about new listings are no more sent, but notifications about new messages still are.

To set up SNS notifications:

1. There needs to be a SNS topic for this. You can create that via AWS UI.
1. Store the SNS topic to config variable "aws_ses_sns_topic". (the string that starts with "arn:aws:sns...")
1. In the SES UI make the sender address use the SNS topic for bounces and complaints.
1. Generate a secret notification token string and store it to config variable "sns_notification_token"
1. Add a subscription to your SNS topic using https and endpoint https://[YOUR_MARKETPLACE_DOMAIN]/bounces?sns_notification_token=[THE_TOKEN_YOU_GENEARATED_IN_LAST_STEP]


#### debugging the SNS setup

If the bounce reports via SNS are working you should at least see those coming in at your server log. You can also add another endpoint (e.g. email) to your SNS topic to be able to debug if something comes that far.


------------------


(There is also third part of SES integration which allows adding new sender addresses via Sharetribe UI, but that's probably not needed to setup for a single marketplace as it's simpler to just add the one sender address needed via the SES UI.)

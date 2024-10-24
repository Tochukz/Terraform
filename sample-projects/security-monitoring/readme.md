# Security Monitoring

### Description

This configuration sets up an integration between CloudTrail and CloudWatch so that CloudTrail logs are logged to CloudWatch log group.  
The logs are also stored in an S3 bucket.

The configuration also provides metric alarm filters that sends out SNS notitification when the root account is used to login and for any unauthorized API calls.

# DevOps Permission

### Description

This configuration produces a custom IAM policy for an IAM user that could be used for an automated deployment tool such as GitHub Action or BitBucket Pipelines.  
The rules allows for frontend deployment to S3 and cloud formation distribution.
The rules also allows for deployment to various types of backend including Lambda functions and ECS containers.

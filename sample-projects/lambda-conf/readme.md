# Lambda Configuration for serverless application
__Zip the source code build__  
```
$ cd example-app
$ zip  ../main.zip main.js  
```  
In a real build and deploy scenario we would have an S3 bucket set aside for staging our archive and would use this to "hand off" these artifacts between the build and deploy process.

__Copy the build to an S3 bucket__  
```
$ aws s3 cp main.zip s3://tochukwu1-bucket/v1.0.0/main.zip
```  
The version number is included in the object path.   

__Trigger the Lambda function using AWS CLI__  
```
$ aws lambda invoke --function-name lambda-func-app output.json 
```  

__To deploy a new version of the application__  
1. Update the body string in example-app/main.js file 
2. create a new zip and upload it with a new version
```
$ cd example-app
$ zip  ../main.zip main.js  
$ aws s3 cp main.zip s3://tochukwu1-bucket/v1.0.1/main.zip
```
3. Deploy the new build 
Deploy the new version using the app_version variable 
```
$ terraform apply -var="app_version=1.0.1"
``` 
Alternatively you can use a variable file 
```
$ terraform apply --var-file lambda.tfvars
```  
4. Roll back to previous version 
```
$ terraform apply -var="app_version=1.0.0"
```

__Learn more__  
[Serverless Applications with AWS Lambda and API Gateway](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/serverless-with-aws-lambda-and-api-gateway)  
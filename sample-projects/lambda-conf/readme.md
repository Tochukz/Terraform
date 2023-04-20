# Lambda Configuration for serverless application
The solution supports
1. Native Node.js application and a
2. Nest.js application  

as two independent root modules.

## Native Node.js application

**Zip the source code build**

```
$ cd node-app
$ zip main.zip main.js
```

In a real build and deploy scenario we would have an S3 bucket set aside for staging our archive and would use this to "hand off" these artifacts between the build and deploy process.

**Copy the build to an S3 bucket**

```
$ aws s3 cp main.zip s3://tochukwu1-bucket/v1.0.0/main.zip
```

The version number is included in the object path.

**Trigger the Lambda function using AWS CLI**

```
$ aws lambda invoke --function-name NativeNode_LambdaFuncApp output.json
```

**To deploy a new version of the application**

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
$ terraform apply --var-file input.tfvars
```

4. Roll back to previous version

```
$ terraform apply -var="app_version=1.0.0"
```

**To debug the API Gateway**

1. Login to the CloudWatch console
2. On the navigation bar, go the _Log_ > _Log groups_
3. Under the Log group table, click on the Log group that looks like: _API-Gateway-Execution-Logs_[api-gatway-id]/[staging]\_.
4. Click on a Log stream
5. Drop down any of the Log events to see the details

**Learn more**  
[Serverless Applications with AWS Lambda and API Gateway](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/serverless-with-aws-lambda-and-api-gateway)  
[API Gateway logging with Terraform](https://medium.com/rockedscience/api-gateway-logging-with-terraform-d13f7701ed0b)

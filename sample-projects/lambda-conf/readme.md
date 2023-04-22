# Lambda Configuration for serverless application
The solution supports
1. Native Node.js application and a
2. Nest.js application  

as two independent root modules.

## Native Node.js application
**Zip the source code build**

```
$ cd node-app
$ zip main.zip app/main.js
```

In a real build and deploy scenario we would have an S3 bucket set aside for staging our archive and would use this to "hand off" these artifacts between the build and deploy process.

**Copy the build to an S3 bucket**
```
$ aws s3 cp main.zip s3://tochukwu1-bucket/v1.0.0/main.zip
```
The version number is included in the object path.

**Trigger the Lambda function using AWS CLI**
```
$ aws lambda invoke --function-name NativeNode_LambdaFuncApp outputs/output1.json
```

**To deploy a new version of the application**
1. Update the body string in node-app/main.js file
2. create a new zip and upload it with a new version
```
$ cd node-app
$ zip  main.zip app/main.js
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

## Nest.js application
For the Nest.js application, the `serverless-express` npm module has been installed  i.e `@vendia/serverless-express`.   
The `lambda.ts` file can be found in the `src` folder. It wraps the express application and exposes it as a lambda handler function.    

__Build and package the application__  
```
$ cd nestsj-app/app
$ npm run build
$ cp -r node_modules dist/
$ cp package.json dist/
$ zip -r dist.zip dist
$ rm -r dist/node_modules
$ rm dist/package.json
```  
Or run the _package_ bash script which contains similar code the the one above. 
```
$ cd nest-app
$ ./package.sh
```

__Copy the packaged application to S3 bucket__   
```
$ aws s3 cp dist.zip s3://tochukwu1-bucket/v1.0.1/dist.zip
```  

**Trigger the Lambda function using AWS CLI**
```
$ aws lambda invoke --function-name NestJS_LambdaFuncApp --region eu-west-2 outputs/output2.json
```

**Learn more**  
[Serverless Applications with AWS Lambda and API Gateway](https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/guides/serverless-with-aws-lambda-and-api-gateway)  
[API Gateway logging with Terraform](https://medium.com/rockedscience/api-gateway-logging-with-terraform-d13f7701ed0b)

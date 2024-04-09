# Simple Laravel Lambda

### Description

This configuration deploys a Lambda function with custom PHP runtime to support a Laravel application.

### Dependency

You Laravel application must have two packages installed: `bref/bref` and `bref/laravel-bridge`.  
So install the packages if you have not already done so.

```bash
$ cd laravel-app
$ composer require bref/bref bref/laravel-bridge --update-with-dependencies
```

### Deployment

1. First deploy the Lambda code to S3

```bash
$ cd scripts
$ ./deploy-code.sh
```

2. Deploy the Terraform configuration

```bash
$ cd simple-laravel-lambda
$ terraform apply
```

The lambda endpoint will be an output from the deployment.

3. Test application
   Copy the lambda endpoint from step 2 to a browser address bar.

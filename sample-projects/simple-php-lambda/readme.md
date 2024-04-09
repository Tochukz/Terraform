# Simple PHP Lambda

### Description

This configuration deploys a Lambda function with custom PHP compatible rumtime.  
It is suitable for running PHP code such as a CLI application but not suitable for PHP website like Laravel.

### Deployment

1. First deploy the Lambd code to S3

```bash
$ cd scripts
$ ./deploy-code.sh
```

2. Deploy the Terraform configuration

```bash
$ cd simple-php-lambda
$ terraform apply
```

3. Test execution

```bash
$ cd scripts
$ ./test-execute.sh
```

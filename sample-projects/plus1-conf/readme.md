# Plus1 Conf
### Description
This project provision AWS resources for a non-trivial web application.  
The major resources provision includes 
* VPC
* EC2 instance 
* RDS instance 
* Cloudfront distribution
* Cognito Userpool and client 
* CodeDeploy App and deployment groups
* SQS Queue
* SNS Topics

### Setup and pre-deployment 
The sections that follows describes the steps that are required before the deployment of the resources.    

__Allocate an elastic IP__  
```
$ aws ec2 allocate-address --domain vpc
```  
The _allocation_id_ obtained from the result will be used for the _allocation_id_ parameter of the _server_ module.  
Elasic IPs are used for the EC2 elastic IP attachment.   

__Generate SSH keys__    
If you are the first person to deploy the infrastrcture, you will need to generate SSH keypairs, otherwise you must download it as described under _Keep the private keys..._ section.   
To generate SSH keypair, run the command in the project root directory.  
```
$ mkdir keys 
$ ssh-keygen -q -f keys/dev -C aws_terraform_ssh_key -N ''
```  
This will generate a public and private key named `dev` in the _keys_ directory.    
You may do the same and replace the -f parameter value by `keys/staging` to generate keys for staging environment and similarly, `keys/prod` for production environment.  
The _keys_ directory has been added to .gitignore to prevent accidental commiting to remote repository.  

__Initialization__  
After cloning the project for the first time, run `terraform init` command for each root module.  
For example, the development network root module
```
$ cd dev/network
$ terraform init 
```
Similarly, you must also run `terraform init` for the other root module when needed.   
For example, to initialize the development server root module
``` 
$ cd dev/server
$ terraform init 
```  

### Deployment
__Deployment__   
To deploy for development environment
```
$ cd dev/network
$ terraform plan -var-file terraform.tfvars
$ terraform apply -var-file terraform.tfvars
```
Similarly, to deploy to staging or production, navigate to _staging_ or _prod_ directory respectively and run the `terraform apply` command in the relevant root module.  

__Deployment order__  
The deployment of the root modules should be done in the order of dependency as follows:  
1. network  
2. data
3. server 
4. frontend  

### Development and changes 
__Backend changes__  
If you change the backend configuration then you must run either `terraform init` with the  `-migrate-state` or `-reconfigure` flag.   
If you wish to attempt automatic migration of the state run `migrate-state`
```  
$ terraform init -migrate-state
```  
Otherwise, if you wish to store the current configuration with no changes to the state run `reconfigure`
```
$ terraform init -reconfigure
```

__Download remote state from S3__   
Sometimes you may have the need to inspect the remote state of a root module.  
To download the remote state of say the development network module: 
```
$ aws s3api get-object --bucket xyz.tochukwu-terraform-states --key plus1-conf/dev/network/terraform.tfstate.json results/dev-network-terraform-tfstate.json
```

### Post deployment
__Keep the private keys with AWS secrets manager__   
If you are the first to deploy the infrastructure, you should save the private key to AWS secrets manager so that other members of your team can access the key.  
Encode the key file content with Base64 encoding and store it in Secrets Manager
```
$ keyBase64=$(base64 keys/dev)
$ aws secretsmanager create-secret --name Plus1ConfDevKey --description "Plus1Conf private key" --secret-string $keyBase64
```  

__Retrieve the private key from secrets manager__  
If someone else deployed the infrastrcture and save the private key to AWS secrets manager, you can access the key by downloading it.  
```
$ aws secretsmanager get-secret-value --secret-id Plus1ConfDevKey --query SecretString --output text | base64 --decode > ~/Plus1ConfDevKey.pem
$ chmod 400 Plus1ConfDevKey.pem
```

__SSH into the EC2 instance__  
If you are using the key you generate yourself in the keys directory
```
$ ssh -i keys/dev ec2-user@xx.xxx.xx.xxx
``` 
If you are using the downloaded key from AWS secrets manager 
```
$ ssh -i ~/Plus1ConfDevKey.pem ec2-user@xx.xxx.xx.xxxx
```  
Replace _xx.xxx.xx.xxxx_ with the public_ip output of your server module deployment.  

### Clean up  
If you are running this for testing or deomonstration purposes you may want to delete all the deployed resources after you are done to avoid charges.   

__Cleanup of resources__   
To destroy all resource in the development frontend modules
```
$ cd dev/frontend
$ terraform destroy -var-file ../terraform.tfvars
```  
Similarly, to destroy all resource in production or staging, navigate to _staging_ or _prod_ directory respectively and run the `terraform destroy` command in the relevant root module.    

__Cleanup order__   
The deletion of the modules resources should be done in the reverse order to the deployment 
1. frontend
2. server 
3. data
4. network

__Release EIP__ 
Unattached Elastic IP attract charges, so you may want to release them as part of your clean up operation.  
Release intially allocated elastic IP  
```
$ aws ec2 release-address --allocation-id eipalloc-04d13ec9ee2acba22
```  

__Delete private key__  
Secrets stored in secrets manager are eligible to charges per secret.  
Delete the private key from secrets manager. 
```
$ aws secretsmanager delete-secret --secret-id Plus1ConfDevKey
```  

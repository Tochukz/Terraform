# Simple EC2 
### Description 
This configuration provisions an EC2 instance with Ubuntu 24.04 64-bit (x86) AMI in the default VPC.   
The security group used for the instance opens up port 80 and 443 for HTTP and HTTPS access.  
It also allows SSH access via the open port 22.  

The simple server is suitable for testing and running simple tasks that required a remote Ubuntu server over a short period of time. 

### Setup 
#### Before deployment 
__Create a keypair__  
A public key file is required for the _aws_key_pair_ resource. 
You can generate a keypair one as follows: 
```bash
$ cd simple-ubuntu
$ mkdir keys
$ ssh-keygen -q -f keys/simple-ubuntu -C aws_terraform_ssh_key -N ''
``` 
This generates a keypair name _simple-ubuntu_ in the _keys_ directory.  

__Linting (Optional)__   
Run linting on the configuration files
```bash
$ cd simple-ubuntu
$ tflint 
```

__Security and compliance scan (Optional)__  
Run scan using _tfsec_ on the configuration files
```bash
$ cd simple-ubuntu
$ tfsec --exclude-path params
```

#### Deployment 
__Get your  cidr block__  
First get you IP address by doing a google search og _my ip_. Then, add _/32_ to it for form your cdir block. 
This cidr block will be used for the ssh_cidr_block variable when prompted in the _plan_ or _apply_ operation below. This may not be applicable if your IP changes regularly.  

If you want to allow any IP to access the instance via SSH, as you may in most test cases, use 0.0.0.0/0 for the ssh_cidr_block variable. This is useful because your IP changes often.  

__Initialization__  
Run terraform init to get your state initialized. 
```
$ terraform init 
```
Note that the configuration uses local state. 

__Planning__   
Run _terraform plan_
```bash
$ terraform plan --var-file params/tfvar.tf
```

__Deployment__   
Run _terraform apply_ 
```bash
$ terraform apply --var-file params/tfvar.tf
```

#### After deployment 
__SSH into the instance__  
First copy the instance_id from the _arn_ output paramter. 
Then run _ec2 describe-instances_ to get your public IP address. 
```bash
$ aws ec2 describe-instances --instance-id i-060df04feb3d6e583 --query "Reservations[0].Instances[0].PublicIpAddress"
```
Use the public IP address to SSH into the instance 
```bash
$ ssh -i keys/simple-ubuntu ubuntu@13.41.70.168
```

__Copy file to remove server__ 
To copy a file source as source code to the remote server: 
```bash
$ zip -r app.zip app
$ scp -i keys/simple-ubuntu app.zip ubuntu@13.40.223.184:~/sources
# Make sure to create ~/sources directory in the remote server before running the scp command
```

__Login to docker__  
After installing docker on the remote instance, you can login to docker 
```bash
$ sudo docker login 
```

#### Clean up
__Destory__ 
To destroy the providion resources and use,
```bash
$ terraform destroy --var-file params/tfvar.tf
```
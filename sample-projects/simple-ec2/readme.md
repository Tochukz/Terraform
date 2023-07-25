# Simple EC2 
### Description 
This configuration provisions an EC2 instance with Ubuntu AMI. 
The security group used for the instance opens up port 80 and 443 for HTTP and HTTPS access. It also allows SSH access via the open port 22. 

The simple server is suitable to test and run simple operations on a remote ubuntu server on a tempoeral basis. 

### Setup 
#### Before deployment 
__Create a keypair__  
A public key file is required for the _aws_key_pair_ resource. 
You can generate a keypair one as follows: 
```bash
$ cd simple-ec2
$ mkdir keys
$ ssh-keygen -q -f keys/simple-ec2 -C aws_terraform_ssh_key -N ''
``` 
This generates a keypair name _simple-ec2_ in the _keys_ directory.  

__Linting (Optional)__   
Run linting on the configuration files
```bash
$ cd simple-ec2
$ tflint 
```

__Security and compliance scan (Optional)__  
Run scan using _tfsec_ on the configuration files
```bash
$ cd simple-ec2
$ tfsec
```

#### Deployment 
__Get your  cidr block__  
First get you IP address by doing a google search og _my ip_. Then, add _/32_ to it for form your cdir block. 
This cidr block will be used for the ssh_cidr_block variable when prompted in the _plan_ or _apply_ operation below.  

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

#### Clean up
__Destory__ 
To destroy the providion resources and use,
```bash
$ tfsec --exclude-path params
```
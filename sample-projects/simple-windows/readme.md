# Simple Windows
### Description
This configuration provisions an EC2 instance with the option of having either Windows Server 2022 _Base AMI_ or Windows Server 2022 _Core Base AMI_ with a 64-bit (x86) architecture.   
The security group used for the instance opens up port 80 and 443 for HTTP and HTTPS access.  
<!-- It also allows SSH access via the open port 22.   -->

The simple server is suitable for testing and running simple tasks that required a remote windows server over a short period of time.

__Windows Server Base AMI Vs Windows Server Core Base AMI__  
1. __Windows Server Base__
* The _Base_ AMI usually includes the full Windows Server installation with the full GUI and Desktop Experience.
* This AMI is suitable for scenarios where administrators prefer managing the server through the GUI and may require certain Windows features and tools that are only available in the Desktop Experience.
2. __Windows Server Core Base__
* The _Core Base_ AMI is a minimal installation option designed for server environments with no graphical user interface.
* This AMI is ideal for headless servers, remote management scenarios, or when administrators prefer managing the server through scripts and remote management tools like Windows Admin Center or PowerShell.

### Setup
### Before deployment
__Create a keypair__  
A public key file is required for the _aws_key_pair_ resource.
You can generate a keypair as follows:
```bash
$ cd simple-windows
$ mkdir keys
$ ssh-keygen -q -f keys/simple-windows5 -C aws_terraform_ssh_key -m PEM
```
This generates a keypair name _simple-windows_ in the _keys_ directory.  
Note that the key generated must be of the RSA format. This is specified by the _PEM_ value of the _-m_ flag. 

__Linting (Optional)__   
Run linting on the configuration files
```bash
$ cd simple-windows
$ tflint
```

__Security and compliance scan (Optional)__  
Run scan using _tfsec_ on the configuration files
```bash
$ cd simple-windows
$ tfsec --exclude-path params
```

### Deployment
__Get your  cidr block__  
First get you IP address by doing a google search of _'my ip'_. Then, add _/32_ to it to form your cdir block.
This cidr block will be used for the ssh_cidr_block variable when prompted in the _plan_ or _apply_ operation below. This may not be applicable if your IP changes regularly.  

If you want to allow any IP to access the instance via SSH, as you may in most test cases, use 0.0.0.0/0 for the ssh_cidr_block variable. This is useful when your IP changes often, which is the case for your local machine.  

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

### After deployment 
#### Connect using Remote Desktop Protocol (RDP)
1. __Install a Remote desktop client__  
__For MacOS users__  
If you are using MacOS , you can download the _Microsoft Remote Desktop_ app from the App store for free. 
__For Windows users__  
Windows usually have _Remote Desktop Connection_ RDC preinstalled. 

2. __Download the _RDP_ shortcut (or create your own)__  
The RDP shortcut enabled you to launch your installed RDP client without having to enter the details of the EC2 instance each time. You only enter your password. 
To download the _RDP_ shortcut
* Go to the EC2 console > instances
* Select the instance by clicking on it's instance ID
* Click on Connect  > RDP Client > Download remote desktop file

3. __Generate password__  
While on the  RDP Client Tab
* Click Get Password 
* Copy the content of your private key and paste in the _private key content_ text area. 
* Click Decrypt password
* Your generated password should be shown on the page. 

4. __Connect to the EC2 instance__  
* Lauch your RD client by clicking on the downloaded RD shortcut 
* You may need to enter the server details like the Public IP and username if you launch the RDP client directly  
* Enter your generated password 
* Connect to the remote instance 

#### Connect using SSH (Not yet tested)
First copy the instance_id from the _arn_ output paramter.
Then run _ec2 describe-instances_ to get your public IP address.
```bash
$ aws ec2 describe-instances --instance-id i-0cb7bca462d354c50 --query "Reservations[0].Instances[0].PublicIpAddress"
```
Use the public IP address to SSH into the instance
```bash
$ ssh -i keys/simple-windows administrator@13.41.70.168
```

__Copy file to remove server__  
To copy a sample source code to the remote server:
```bash
$ zip -r app.zip app
$ scp -i keys/simple-windows app.zip administrator@13.40.223.184:~/sources
# Make sure to create ~/sources directory in the remote server before running the scp command
```

__Login to docker__  
After installing docker on the remote instance, you can login to docker
```bash
$ sudo docker login
```

### Clean up
__Destory__  
To destroy the providion resources and use,
```bash
$ terraform destroy --var-file params/tfvar.tf
```

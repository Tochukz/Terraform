# Terraform Up and Running (2017)
__By Yevgenic Brikman__   
[Github Code Examples](https://github.com/brikis98/terraform-up-and-running-code)
[Terraform Docs](https://developer.hashicorp.com/terraform/docs)  
[Terraform Providers](https://registry.terraform.io/browse/providers)  
[AWS Providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
[Azure Providers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)   

## Chapter 1: Why Terraform
__The rise of DevOps__   
Applying DevOPs practices can reduce _lead times_ significantly for an organization.  
There are four core values in the DevOps movement: _Culture_, _Automation_, _Measurement_ and _Sharing_ (sometimes abbreviated as the acronym CAMS).  

__What is infrastructure as code__  
There are four broad categories of IAC tools:
1. Ad hoc scripts - Bash Script, Python, Ruby.
2. Configuration management tools - Ansible, Chef, Puppet and SlatStack.
3. Server templating tools - Docket, Packer and Vagrant.
4. Orchestration tools - Terraform, CloudFormation and OpenStack Heat.

## Chapter 2: An Introduction to Terraform Syntax
[AWS in Plain English](https://expeditedsecurity.com/aws-in-plain-english/)

__Installing Terraform__  
For MacOS
```
$ brew tap hashicorp/tap
$ brew install hashicorp/tap/terraform
$ terraform --version
```
For other Operating Systems, see [Install Terraform](https://developer.hashicorp.com/terraform/downloads)  
Terraform uses you configured AWS credential, so you do not need to do anything if you already have AWS CLI   configured.  

You may also install the _autocomplete package_:   
```
$ terraform -install-autocomplete
```
__Deploy a Single server__  
Terraform code is written in the _HashiCorp Configuration Language_ (HCL) in files with the extension `.tf`.     

[AWS Instance Types](https://aws.amazon.com/ec2/instance-types/)  

After creating your terraform configuration file, or after cloning a terraform project from a repository, you navigate into the folder and run the `inti` command:  
```
$ terraform init
```
This downloads and installs the providers defined in the configuration. It will also create a lock file named `.terraform.lock.hcl`.   
Remember to add `.terraform` to your `.gitignore` file.    

Now run the `plan` command to show the changes that are required for your infrastructure:
```
$ terraform plan  
```  

To format and validate your configuration, run the `fmt` command:
```
$ terraform fmt
```  

To ensure that your configuration is syntactically valid and internally consistent run the `validate` command:  
```
$ terraform validate
```

To create the infrastructure defined in the configuration run the `apply` command:    
```
$ terraform apply
```  

After the resources are created, terraform generate a `terraform.tfstate` file which it uses to manage the state of the resources.  
To inspect the current state, use the `show` command:  
```
$ terraform show
```  

The `state` command is for advanced state management. Use the `list` subcommand to list the resources in your project's state:  
```
$ terraform state list  
```  

__Cidr block__  
For a handy calculator that converts between IP address ranges and CIDR notation, see [ipaddressguide.com/cidr](https://www.ipaddressguide.com/cidr)

__Input variable__  
The syntax for defining variable is as follows   
```
variable "variablename" {
  description = ""
  type = ""
  default = ""
}
```  
The `type` may be
1. string
2. number
3. bool
4. list (or tuple)
5. map (or object)

The value for variable can be provided in a number of ways:
* passing it in at the command line using the _-var_ option
```
$ terraform plan -var server_port=80
```
* via a file using the _-var-file_ option
* via an environment variable  of the name *TF_VAR_<variable_name>*  
If no value is passed in, the variable will fall back to this default value. If there is no default value, Terraform will interactively prompt the user for one.  

__Resource Dependency__  
Terraform shows you the dependency graph by running the graph command:
```
$ terraform graph
```  
__Resource changes__  
In Terraform, most changes to an EC2 Instance, other than metadata such as tags, actually create a completely new Instance.  

__Output__  
Use the _terraform output_ command to list outputs without applying any changes and _terraform output OUTPUT_NAME_ to see the value of a specific output.
```
$ terraform output
$ terraform output public_ip
```

[A Comprehensive Guide to Building a Scalable Web App on Amazon Web Services - Part 1](https://www.airpair.com/aws/posts/building-a-scalable-web-app-on-amazon-web-services-p1)

## Chapter 3: How to manage Terraform state  
__Backend Configuration__    
Terraform uses persisted state data to keep track of the resources it manages.  
A _backend_ defines where Terraform stores its state data files.  
Most non-trivial Terraform configurations either integrate with _Terraform Cloud_ or use a backend to store state remotely.  
By default, Terraform uses a backend called _local_, which stores state as a local file on disk.   

When you change a backend's configuration, you must run `terraform init` again to validate and configure the backend before you can perform any _plans_, _applies_, or state operations.

__S3 Backend configuration__   
To configure S3 for remote storage of state,
first create the S3 bucket and enable object versioning
```
$ aws s3 mb s3://xyz.tochukwu-terraform-states
$ aws s3api put-bucket-versioning --bucket xyz.tochukwu-terraform-states --versioning-configuration Status=Enabled
```
AWS recommends that you wait for 15 minutes after enabling versioning before issuing write operations (PUT or DELETE) on objects in the bucket.  

You may also enable server-side encryption on the S3 bucket
```
$ aws s3api put-bucket-encryption --bucket xyz.tochukwu-terraform-states --server-side-encryption-configuration file://s3-encryption-config.json
```

__State lock__  
To enable state locking, for your S3 backend, you may create a dynamoDB
```
$ aws dynamodb create-table --table-name terraform_states_lock  --attribute-definitions AttributeName=LockID,AttributeType=S  --key-schema AttributeName=LockID,KeyType=HASH  --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```  

__Backend block__  
To use the S3 backend and dynamoDB for state lock for your backend, you add a backend block to your terraform template
```
terraform {
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "my-solution/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}
```
At anytime you can download your `terraform.tfstate` file from the S3 bucket
```
$ aws s3api get-object --bucket xyz.tochukwu-terraform-states --key my-solution/terraform-tfstate.json results/terraform-tfstate.json
```

__State migration__    
When you make changes to the _backend_ block that affects the state location, you need to run `terraform init` with the `-migrate-state` or `-reconfigure` flag.
```
$ terraform init -migrate-state
```  

__Learn More__   
[Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/configuration)   
[S3 Backend Configuration](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

## Chapter 4: How to create reusable infrastructure with Terraform modules  
__Modules Basics__  
Whenever you add a module to your Terraform templates or modify its source parameter, you need to run the get command before you run plan or apply:  
```
$ terraform get
$ terraform plan
```  
If you update your module you may need to call the `get` command with `-update` flag.  
```
$ terraform get -update
```   

__Inline blocks__  
The configuration for some Terraform resources can be defined either as inline blocks or as separate resources. When creating a module, you should always prefer using a separate resource.   
If you try to use a mix of both inline blocks and separate resources, you will get errors where routing rules conflict and overwrite each other. Therefore, you must use one or the other.

## Chapter 5: Terraform tips & tricks: loops, if- statements, deployment, and gotchas
Terraform provides a few primitives — namely, a meta-parameter called _count_, a lifecycle block called _create_before_destroy_, plus a large number of interpolation functions that allow you to do certain types of loops, if-statements, and zero-downtime deployments.  

__Loop__  
almost every Terraform resource has a meta-parameter you can use called _count_.  
This parameter defines how many copies of the resource to create.  
In terraform you can loop by using _count.index_ and two interpolation functions: _element_ and _length_.  

```
resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name = "${element(var.user_names, count.index)}"
}
```
User _user_names_ is an variable of type _list(string)_.

To learn more about the [interpolation syntax](https://developer.hashicorp.com/terraform/language/v1.1.x/configuration-0-11/interpolation)

An _IAM policy_ consists of one or more statements, each of which specifies an effect (either “Allow” or “Deny”), on one or more actions (e.g. “ec2:Describe*” allows all API calls to EC2 that start with the name “Describe”), on one or more resources (e.g. “*” means “all resources”).
```
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:Describe*"],     
      "Resource": ["*"]
    }
  ]
}
```  

__Simple if-statements__   
In Terraform, if you set a variable to a boolean _true_ it will be converted to a 1 and if you set it to a boolean _false_, it will be converted to a 0.  
If you set _count_ to 1 on a resource, you get one copy of that resource and if you set _count_ to 0, that resource is not created at all.  

__More complicated if-statements__   

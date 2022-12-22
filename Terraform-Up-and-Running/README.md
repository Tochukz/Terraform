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
There are four code values in the DEvOps movement: Culture, Automation, Measurement and Sharing (sometimes abbreviated as the acronym CAMS).  

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
For other OS, see [Install Terraform](https://developer.hashicorp.com/terraform/downloads)  
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

To ensure that your configuration is syntactically valid and internally consistent run the `validate` command.  
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
The `type` may be _string_, _list_, or _map_.   
The value for variable can be provided in a number of ways:
* passing it in at the command line using the _-var_ option
```
$ terraform plan -var server_port=80
```
* via a file using the _-var-file_ option
* via an environment variable  of the name *TF_VAR_<variable_name>*  
If no value is passed in, the variable will fall back to this default value. If there is no default value, Terraform will interactively prompt the user for one.  
__Resource Dependency__
Terraform to show you the dependency graph by running the graph command:
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

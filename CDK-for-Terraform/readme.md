# Cloud Development Kit for Terraform (CDKTF)
[Docs](https://developer.hashicorp.com/terraform/cdktf)   
[CDK Tutorial](https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install)     

__How does CDK for Terraform work?__  
CDK for Terraform leverages concepts and libraries from the AWS Cloud Development Kit to translate your code into infrastructure configuration files for Terraform.
__NB:__ CDKTF is currently on version _0.15.x_ and may still have breaking changes before its 1.0 release.  

## Chapter 1: Getting started
__Prerequisites__   
* Terraform CLI (1.2+)
* Node.js and npm v16+.
* A Programming language e.g TypeScript, Java, C#, Go or Python
* Docker (Optional)

__Install CDKTF__   
```
$ npm install --global cdktf-cli@latest
$ cdktf help
```

__Create and initialize a project__   
Create the project directory
```
$ mkdir nginx-server
$ cd nginx-server
```
Initialize CDKTF with the appropriate template
```
$ cdktf init --template=typescript --providers=kreuzwerker/docker --local
```  
A Docker provider was specified, and we included the _--local_ flag to prevent CDKTF from using _Terraform Cloud_.   

To initialize a project with AWS provider
```
$ cdktf init --template="typescript" --providers="aws@~>4.0"
```
If you would prefer to keep your state locally, use the `--local` flag with `cdktf init`.

__Use Providers__   
You can add prebuilt providers (if available) or locally generated ones using the add command:
```
$ cdktf provider add "aws@~>3.0" null kreuzwerker/docker
```  
You can find all prebuilt providers on npm: https://www.npmjs.com/search?q=keywords:cdktf  
You can also install these providers directly through npm:
```
$ npm install @cdktf/provider-aws
$ npm install @cdktf/provider-google
$ npm install @cdktf/provider-azurerm
$ npm install @cdktf/provider-docker
$ npm install @cdktf/provider-github
$ npm install @cdktf/provider-null
```  
You can also build any module or provider locally. Learn more https://cdk.tf/modules-and-providers  

__Deploy__   
Use `cdktf deploy` to compile your code and deploy the stack
```
$ cdktf deploy
```  
You will be prompted with 3 options:
* Approve
* Dismiss
* Stop
You may select the _Approve_ option to proceed with the deployment.   

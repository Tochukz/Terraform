# Plus1 Conf
__Description__  

__Setup__  
To get setup, after cloning the project, run `terraform init` command for a particular root module. 
For example for the development network root module
```
$ cd dev/network
$ terraform init 
```
Similarly, you must also run `terraform init` for the other module when needed. For example to setup staging server 
``` 
$ cd staging/server
$ terraform init 
```  

__Backend changes__  
If you change the backend configuration then you must run either `terraform init` with the  `-migrate-state` or `-reconfigure` flag.   
If you wish to attempt automatic migration of the state run `migrate-state`
```  
$ terraform init -migrate-state
```  
But if you wish to store the current configuration with no changes to the state run `reconfigure`
```
$ terraform init -reconfigure
```

__Deployment__   
To deploy for development environment
```
$ cd dev/network
$ terraform plan -var-file terraform.tfvars
$ terraform apply -var-file terraform.tfvars
```
Similarly, to deploy to staging or production, navigate to _staging_ or _prod_ directory respectively and run the `terraform apply` command.

__Cleanup__  
To destroy all resource for development environment
```
$ cd dev
$ terraform destroy -var-file ../terraform.tfvars
```  
Similarly, to destroy all resource in production or staging, navigate to _staging_ or _prod_ sirectory respectively and run the `terraform destroy` command.  

__Deployment order__  
The deployment of the modules should be done in the following order.  
1. network  
2. database
3. server 
4. frontend  

__Cleanup order__   
The destroy of the modules should be done in the reverse order to the deployment 
1. frontend
2. server 
3. database 
4. network 
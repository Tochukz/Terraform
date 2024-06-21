# Simple Container
### Description
This configuration provisions an ECS container with it's dependent resources.  
The configuration is made to be simple for low to medium traffic so it is not suitable when scalability is a requirement.  
See _advanced-container_ sample-project for a scalable container configuration.

### Setup
__Build Image__  
Build a Docker image from sample application
```bash
$ cd sample-apps/express-app
$ docker build -t simple-express-app .
```
Run a container to test the image
```bash
$ docker run -dp 8081:80 simple-express-app
```
Launch the app by going to http://localhost:8081 .   
You can remove the container after the testing.
```bash
# Get the container id
$ docker ps
$ docker rm -f <container-id>
```

__Create ECR Repo__  
Create an AWS ECR repository
```bash
$ aws ecr create-repository --repository-name simple-express-repo
```
Copy the `repository.repositoryUri` value from the output of the newly created repository. This value will be used for the `ecr_repository_url` variable in the configuration and also to tag the local docker image.

__Push Image to ECR Repo__  
1. Authenticate your Docker client to access AWS ECR
```bash
$ aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com
```
2. Tag the local image with the remote repository url copied from the repository creation.
```bash
$ docker tag simple-express-app <respository-uri>
```
Generally it should following the structure
```bash
$ docker tag <repository_name>:latest <respository-uri>:latest
```
3. Push the image to ECR
```bash
$ docker push <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo
```

__Deploy the configuration__  
```bash
$ terraform apply
```

__Test the application__  
A public IP address is automatically assigned to the ECS service. You can use this public IP to access the application.  
Go to AWS ECS Console > Cluster > Select the cluster > Services > Select the service > Tasks > Select the task > Configuration tab > Configuration section, you will see the public IP address for the service.  
Copy the public IP address to your browser.  

You can add an `A` record in your DNS control to point to the IP address.

Host	 | TTL	| Type	|Value
-------|------|-------|------
app    | 3600 |  A    | 35.178.249.54

After a few minutes, you should be able to access the application at http://app.yourdomain.com

__Update ECS Container__  
After you may have made changes to your application code, you need to push an updated image and then update the ECS service.
```bash
# Build the image again and push it
$ docker build -t simple-express-app
$ docker tag simple-express-app <respository-uri>
$ docker push <respository-uri>
# Update the ECS Service using the cluster name and service name
$ aws ecs update-service --cluster simple-cluster --service simple-service --force-new-deployment
# Check Service status
$ aws ecs describe-services --cluster <cluster_name> --service <service_name>
```
Note that after the ECS service is updated, the public IP address will change. You have to go back to the ECS console to get the new public IP address to test the updated application.  

__Clean up__  
Destory all the resource
```bash
$ terraform destroy
```
Delete the ECR repository
```bash
# Make sure all the repository images are already deleted
$ aws ecr delete-repository --repository-name simple-express-repo
```

__Resources__   
[How do I deploy updated Docker images to Amazon ECS tasks](https://stackoverflow.com/questions/34840137/how-do-i-deploy-updated-docker-images-to-amazon-ecs-tasks)  
[ECS Fargate Docker container securely hosted behind API Gateway using Terraform](https://medium.com/@chetlo/ecs-fargate-docker-container-securely-hosted-behind-api-gateway-using-terraform-10d4963b65a3)  

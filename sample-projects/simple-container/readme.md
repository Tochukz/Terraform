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
Copy the `repository.repositoryUri` value from the output of the newly created repository. This value will be used for the `ecr_repository_url` variable in the configuration.  

__Push Image to ECR Repo__  
1. Authenticate your Docker client to access AWS ECR
```bash
$ aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com
```
2. Tag the image for ECR
```bash
$ docker tag simple-express-app <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo
```
Generally it should following the structure
```bash
$ docker tag <repository_name>:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository_name>:latest
```
3. Push the image to ECR
```bash
$ docker push <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo
```

__Update ECS Container__  
After you may have made changes to your application code, you need to push an updated image and then update the ECS service. 
```bash
# Build the image again and push it
$ docker build -t 665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo .
$ docker push 665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo
# Update the ECS Service using the cluster name and service name
$ aws ecs update-service --cluster simple-cluster --service simple-service --force-new-deployment
# Check Service status
$ aws ecs describe-services --cluster <cluster_name> --services <service_name>
```

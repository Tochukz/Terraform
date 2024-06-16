# Simple Container
### Description
This configuration provisions an ECR repository.

### How to use
1. Deploy the configuration
```bash
$ terraform apply
```
This creates the ECR repository.

2. Push you docker image to the respository.  
   See the instructions below on _How to push an image to ECR_.

### Operations
**How to push an image to ECR**
1. Retrieve an authentication token and authenticate your Docker client to your registry.
```bash
$ aws ecr get-login-password | docker login --username AWS --password-stdin 665778208875.dkr.ecr.eu-west-2.amazonaws.com
```

2. Build your Docker image
```bash
$ docker build -t simple-express .
```

3. Tag your image so you can push the image to the repository:
```bash
$ docker tag simple-express:latest 665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express:latest
```
4. Push this image to your newly created AWS repository:
```bash
$ docker push 665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express:latest
```

You can view these push command for the ECR repository on the management console.  
Just go to the repository page and click the _View Push Commands_ button.

### Learn more
[Deploying Docker Containers to AWS ECS Using Terraform](https://earthly.dev/blog/deploy-dockcontainers-to-awsecs-using-terraform/)

[Github Sample Code](https://github.com/Rose-stack/docker-aws-ecs-using-terraform)

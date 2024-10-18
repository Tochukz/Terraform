# Advance Container
### Description
This configuration provisions an ECS container for a NodeJS application. All the other dependent services are also configured including VPC, Subnets, Application Load Balancer etc, thus making it an advance configuration.

### Setup
__ECR Repository__    
Before the configuration can be deployed, an ECR repository must have been configured. This ECR repository URL must be used for the `ecr_repository_url` variable.
You can create your repository and push an image to it by going through the following steps.

1. Create a repository
```bash
$ aws ecr create-repository --repository-name simple-express-repo
```
2. Retrieve an authentication token and authenticate your Docker client to your registry.
```bash
$ aws ecr get-login-password | docker login --username AWS --password-stdin xxxxxxxx.dkr.ecr.eu-west-2.amazonaws.com
```
The number `xxxxxxxx` should be your AWS account number which you can find by running `aws sts get-caller-identity`
3. Build your Docker image
```bash
$ cd sample-apps/express-app
$ docker build -t express-app .
```
4. Tag your image so you can push the image to the repository:
```bash
$ docker tag express-app:latest xxxxxxxx.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo:latest
```
5. Push this image to your newly created AWS repository:
```bash
$ docker push xxxxxxxx.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo:latest
```

You can view these push command for the ECR repository on the management console.  
Just go to the repository page and click the _View Push Commands_ button.

__Certificate ARN__  
The configuration also requires a certificate which must be passed for the `certificate_arn` variable.
You can go to the ACM Console to request an ACN certificate.
Add the a CNAME record to your DNS configuration as follows:

Host         | TTL  | Type  | Value         
------------ | ---- | ----- | -------------
[CNAME name] | 3600 | CNAME | [CNAME value]

### Deployment
Deploy the configuration
```bash
$ terraform apply
```

### After Deploy
__Add CNAME to you DNS config__     
After deployment, the application load balancer DNS name will be shown on the terminal under the name `lb_dns_name`.
Add a CNAME record to you DNS setup as follows

Host| TTL  | Type  | Value         
----|------|-------|-------------
app | 3600 | CNAME | [LB DNS Name]

You can then use your newly created subdomain to access your application like this https://app.yourdomain.com .

### Learn more
[Deploying Docker Containers to AWS ECS Using Terraform](https://earthly.dev/blog/deploy-dockcontainers-to-awsecs-using-terraform/)  
[Github Sample Code](https://github.com/Rose-stack/docker-aws-ecs-using-terraform)

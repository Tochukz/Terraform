variable "env_name" {
  description = "The deployment environment e.g dev, staging or prod"
}

variable "region" {
  description = "The AWS region e.g eu-west-2"
}

variable "subscribe_email" {
  description = "Email address to subscribe to SNS topic e.g john.smith@gmail.com"
}

variable "subscribe_endpoint" {
  description = "API endpoint to subscribe to SNS topic e.g https://api.myapp.com/subscribe/deployments"
}

variable "ecr_repository_url" {
  type        = string
  description = "URL of the ECR repository"
  default     = "665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo"
}

variable "env_variables" {
  type        = map(any)
  description = "Environment variables"
  default = {
    PORT     = 80
    NODE_ENV = "production"
  }
}


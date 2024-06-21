variable "ecr_repository_url" {
  type        = string
  description = "The repository URI for the docker image"
  default     = "665778208875.dkr.ecr.eu-west-2.amazonaws.com/simple-express-repo"
}
variable "container_name" {
  type        = string
  description = "A name for the container"
  default     = "ExpressAppContainer"
}
variable "env_variables" {
  type        = map(any)
  description = "Environment variables"
  default = {
    PORT     = 80
    NODE_ENV = "advanced-production"
  }
}
variable "certificate_arn" {
  type        = string
  description = "ARN of SSL certificate"
  default     = "arn:aws:acm:eu-west-2:665778208875:certificate/f1d8c127-b68a-4fac-8147-f987ff4f8ab4"
  validation {
    condition     = can(regex(".*acm:eu-west-2.*", var.certificate_arn))
    error_message = "The ACM certificate must be from the eu-west-2 region."
  }
}

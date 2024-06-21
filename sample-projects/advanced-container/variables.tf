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

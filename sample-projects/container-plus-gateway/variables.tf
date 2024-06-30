variable "environment_name" {
  type        = string
  description = "A friendly environment name that will be used for namespacing all cluster resources. Example: staging, qa, or production"
  default     = "escapei-demo"
}
variable "private_dns_namespace_name" {
  type        = string
  description = "The private DNS name that identifies the name that you want to use to locate your resources"
  default     = "service"
}
variable "min_containers_foodstore_foods" {
  type        = number
  description = "Minimum number of ECS tasks per ECS service"
  default     = 3
}
variable "max_containers_foodstore_foods" {
  type        = number
  description = "Maximum number of ECS tasks per ECS service"
  default     = 30
}
variable "auto_scaling_target_value_foodstore_foods" {
  type        = number
  description = "Target CPU utilization (%) for ECS services auto scaling"
  default     = 50
}
variable "min_containers_petstore_pets" {
  type        = number
  description = "Minimum number of ECS tasks per ECS service"
  default     = 3
}
variable "max_container_petstore_pets" {
  type        = number
  description = "Maximum number of ECS tasks per ECS service"
  default     = 30
}
variable "auto_scaling_target_value_petstore_pets" {
  type        = number
  description = "Target CPU utilization (%) for ECS services auto scaling"
  default     = 50
}

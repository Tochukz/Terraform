variable "region" {
  description = "The AWS region e.g eu-west-2"
}
variable "env_name" {
  description = "The deployment environment e.g dev, staging, prod"
}
variable "dbname" {
  description = "Database name"
}
variable "username" {
  description = "Database username"
}
variable "password" {
  description = "Database password"
}
variable "network_state_key" {
  description = "The object key for the state which is stored in S3 bucket for the network module"
}
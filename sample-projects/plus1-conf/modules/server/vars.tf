
variable "env_name" {
  description = "The name of the deployment environment"
}
variable "region"  {
  description = "The AWS region"
}
variable "allocation_id" {
  description = "An allocation ID of an elasic IP"
}
variable "instance_type" {
  description = "The ec2 instance type"
}
variable "network_state_key" {
  description = "The object key for the state which is stored in S3 bucket"
}
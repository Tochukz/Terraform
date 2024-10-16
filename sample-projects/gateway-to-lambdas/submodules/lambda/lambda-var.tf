variable "function_name" {
  type = string 
  description = "Name of the Lambda function"
}
variable "artifact_bucket" {
  type = string 
  description = "Artifact bucket name"
}
variable "artifact_key" {
  description = "The key to the code packge e.g v0.0.1/user-management.zip"
}
variable "role_arn" {
  type = string 
  description = "ARN of the role for the Lambda"
}
variable "layer_arns" {
  type = list(string)
  description = "List of layer ARNs"
}
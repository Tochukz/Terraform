variable "path_path" {
  type = string
  description = "The path for the api gateway resource"
}
variable "rest_api_id" {
  type = string
  description = "The id of the api gateway"
}
variable "root_resource_id" {
  type = string 
  description = "The root resource id of the api gateway"
}
variable "lambda_invoke_arn" {
  type = string 
  description = "Invocation ARN for the Lambda function for the microservice"
}
variable "lambda_func_name" {
  type = string 
  description = "Name of the Lambda function for the microservice"
}
variable "execution_arn" {
  type = string 
  description = "API gateway execution arn"
}
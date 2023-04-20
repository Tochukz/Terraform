variable "app_version" {
  description = "The version of the application build"
  default     = "1.0.0"
}
variable "app_name" {
  description = "The name for your app"
}
variable "build_name" {
  description = "The name of the zip file containing the build"
}
variable "handler" {
  description = "The handler function name of the lambda handler"
}

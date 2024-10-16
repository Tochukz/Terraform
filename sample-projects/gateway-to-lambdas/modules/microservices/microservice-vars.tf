variable "artifact_bucket" {
  type    = string
  description = "The S3 bucket that houses the Lambda and Lambda Layer code"
}
variable "artifact_version" {
  type    = string
  description = "The version for the Lambda code and Lambda Layer"
}
variable "layer_version" {
  type = number
  description = "Layer version number"
}
variable "stage_name" {
  type    = string
  description = "The stagename for the API gateway"
}
variable "env" {
  type = string
  description = "The envrionemnt name e.g dev"
}

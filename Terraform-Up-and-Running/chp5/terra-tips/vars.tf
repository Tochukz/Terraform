variable "user_names" {
  description = "A array of names for IAM users"
  type = list(string)
  default = ["leo", "trinity", "morpheus"]
}

variable "add_bucket" {
  description = "If set to true an S3 bucket is created"
  type = bool
}
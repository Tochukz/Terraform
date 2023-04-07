variable "env_name" {
  description = "The deployment environement name, e.g dev"
}
variable region {
  description = "The AWS region, e.g eu-west-2"
}
variable "certificate_arn" {
  description = "AWS ACM certificate ARN"
}
variable "alternate_domains" {
  description = "Alernate domain names"
  type = list(string)
}
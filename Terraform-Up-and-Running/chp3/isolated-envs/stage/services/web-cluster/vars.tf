variable "server_port" {
  description = "Port for HTTP request"
  default = 80
}

variable "key_name" {
  description = "Key name of existing keypair"
  default = "AmzLinuxKey2"
}

variable "avail_zones" {
  description = "Availability zones"
  default = ["eu-west-2a", "eu-west-2b"]
}

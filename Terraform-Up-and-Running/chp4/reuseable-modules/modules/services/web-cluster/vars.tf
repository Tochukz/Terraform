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

variable "cluster_name" {
  description = "The name for the cluster"
}

variable "db_state_key" {
  description = "S3 bucket object key for the database's remote state"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in auto-scaling group"
}

variable "max_size" {
  description = "Maximum number of EC2 instances in auto-scaling group"
}
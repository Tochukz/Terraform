variable "region" {
  type = string
  description = "The AWS region for the deployment e.g eu-west-2"
}
variable "instance_type" {
  type = string
  description = "The EC2 instance type"
   validation {
    condition = contains(["t2.nano", "t2.micro"], var.instance_type)
    error_message = "You must use only t2.nano or t2.micro instance type to save cost"
  }
}
variable "ssh_cidr_block" {
  type = string
  description = "The IP address block, that includes your own IP, for SSH access. To allow SSH access from any machine, type 0.0.0.0/0"  
}

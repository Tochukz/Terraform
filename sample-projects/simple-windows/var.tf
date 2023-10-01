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
variable "install_option" {
  type = string
  description = "The windows installation option could be core or base. Core is minimalistic non GUI while base is the traditional GUI based installtion"
  validation {
    condition = contains(["base", "core"], var.install_option)
    error_message = "Window installation option must either be core or base"
  }

}
variable "ssh_cidr_block" {
  type = string
  description = "The IP address block, that includes your own IP, for SSH access. To allow SSH access from any machine, type 0.0.0.0/0"  
}

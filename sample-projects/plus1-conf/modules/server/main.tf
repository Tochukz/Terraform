locals {
  regions = {
    eu-west-1 = {
      ami = "ami-08fea9e08576c443b"
    }
    eu-west-2 = {
      ami = "ami-0055e70f580e9ae80"
    }
    eu-west-3 = {
      ami = "ami-09352f5c929bf417c"
    }
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "xyz.tochukwu-terraform-states"
    key = var.network_state_key
    region = var.region
  }
}

resource "aws_key_pair" "keypair" {
  key_name = "Plus1Conf-${var.env_name}-KeyPair"
  public_key = file("../../keys/${var.env_name}.pub")
}

resource "aws_instance" "server_instance" {
  ami = local.regions[var.region].ami
  subnet_id = data.terraform_remote_state.network.outputs.public_subnet_id
  key_name = aws_key_pair.keypair.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [data.terraform_remote_state.network.outputs.web_sg_id]
  associate_public_ip_address = true
  user_data = file("${path.module}/user-data.sh")
}

resource "aws_network_interface_attachment" "web_network_attach" {
  network_interface_id = data.terraform_remote_state.network.outputs.network_interface_id
  instance_id = aws_instance.server_instance.id
  device_index = 1
}

resource "aws_eip_association" "instance_eip_assoc" {
  allocation_id = var.allocation_id
  network_interface_id = data.terraform_remote_state.network.outputs.network_interface_id
}

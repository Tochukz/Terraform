terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "server_port" {
  description = "Port for HTTP request"
  default = 80
}

variable "key_name" {
  description = "Key name of existing keypair"
  default = "AmzLinuxKey2"
}

data "aws_availability_zones" "simple_avail_zones" {
  # state = "available"
  all_availability_zones = true
}

resource "aws_security_group" "web_security_group" {
  name = "simple_server_sg"
  ingress {
    from_port= "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "lb_security_group" {
  name = "loadbalancer_sg"
  ingress {
    from_port = 80
    to_port = 89 
    protocol = "tpc"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "simple_launch_config" {
  image_id           = "ami-04706e771f950937f"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_security_group.id}"]
  key_name =  "${var.key_name}"
  user_data ="sudo amazon-linux-extras install nginx1 -y \n sudo service nginx start"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "simple_loadbalancer" {
  name = "app-load-balancer"  
  availability_zones = data.aws_availability_zones.simple_avail_zones.names
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = var.server_port
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2 
    timeout = 3 
    interval = 30
    target = "HTTP:${var.server_port}/"
    //path = "/"
  }
}

resource "aws_autoscaling_group" "simple_autoscaling_group" {
  launch_configuration = "${aws_launch_configuration.simple_launch_config}" 
  availability_zones = [data.aws_availability_zones.simple_avail_zones.names]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.simple_loadbalancer.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "app-autoscaling-group"
    propagate_at_launch = true
  }
}

output "elb_dns_name" {
  value = "${aws_elb.simple_loadbalancer.dns_name}"
}

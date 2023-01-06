terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key = "isolated-envs/stage/services/web-cluster/terraform-tfstate.json"
    region = "eu-west-2"
    dynamodb_table = "terraform_states_lock"
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "terraform_remote_state" "db_state" {
  backend = "s3"
  config = {
    bucket = "xyz.tochukwu-terraform-states"
    key = "isolated-envs/stage/data-store/mysql/terraform-tfstate.json"
    region = "eu-west-2"
  }
}

data "template_file" "user_data" {
  template = file("user-data.sh")
  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db_state.outputs.db_address 
    db_port = data.terraform_remote_state.db_state.outputs.db_port
  }
}

resource "aws_security_group" "web_security_group" {
  name = "simple-server-sg"
  ingress {
    from_port= var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22 
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
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
    to_port = 80 
    protocol = "tcp"
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
  name = "simple-launch-config"
  image_id  = "ami-04706e771f950937f"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.web_security_group.id}"]
  key_name =  "${var.key_name}"
  user_data = data.template_file.user_data.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "simple_loadbalancer" {
  name = "app-load-balancer"  
  availability_zones = var.avail_zones
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
  }
}

resource "aws_autoscaling_group" "simple_autoscaling_group" {
  name = "simple-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.simple_launch_config.name}"
  availability_zones = var.avail_zones
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

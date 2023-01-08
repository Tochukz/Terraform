data "terraform_remote_state" "db_state" {
  backend = "s3"
  config = {
    bucket = "xyz.tochukwu-terraform-states"
    key = "${var.db_state_key}"
    region = "eu-west-2"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db_state.outputs.db_address 
    db_port = data.terraform_remote_state.db_state.outputs.db_port
  }
}

resource "aws_security_group" "web_security_group" {
  name = "${var.cluster_name}-simple-server-sg"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.web_security_group.id
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.web_security_group.id
  from_port = 22 
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = aws_security_group.web_security_group.id 
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "lb_security_group" {
  name = "${var.cluster_name}-loadbalancer-sg"
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
  name = "${var.cluster_name}-simple-launch-config"
  image_id  = "ami-04706e771f950937f"
  instance_type = var.instance_type
  security_groups = ["${aws_security_group.web_security_group.id}"]
  key_name =  "${var.key_name}"
  user_data = data.template_file.user_data.rendered
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "simple_loadbalancer" {
  name = "${var.cluster_name}-load-balancer"  
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
  name = "${var.cluster_name}-simple-autoscaling-group"
  launch_configuration = "${aws_launch_configuration.simple_launch_config.name}"
  availability_zones = var.avail_zones
  min_size = var.min_size
  max_size = var.max_size
  load_balancers = ["${aws_elb.simple_loadbalancer.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "${var.cluster_name}-app-autoscaling-group"
    propagate_at_launch = true
  }
}

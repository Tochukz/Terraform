resource "aws_default_vpc" "default_vpc" {

}

resource "aws_default_subnet" "subnet_a" {
  availability_zone = "eu-west-2a"
}

resource "aws_default_subnet" "subnet_b" {
  availability_zone = "eu-west-2b"
}

resource "aws_security_group" "simple_lb_sg" {
  name        = "SimpleLoadBalancerSG"
  description = "Allow trafic from any source on the internet"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "simple_service_sg" {
  name        = "SimpleServiceSG"
  description = "Only allowing traffic in from the load balancer security group"
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.simple_lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "app_load_balancer" {
  name               = "simple-load-balancer"
  load_balancer_type = "application"
  subnets            = [aws_default_subnet.subnet_a.id, aws_default_subnet.subnet_b.id]
  security_groups    = [aws_security_group.simple_lb_sg.id]
}

resource "aws_lb_target_group" "simple_lb_target" {
  name        = "SimpleLbTarget"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}


resource "aws_lb_listener" "simple_lb_listener" {
  load_balancer_arn = aws_alb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.simple_lb_target.arn
  }
}

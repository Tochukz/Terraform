resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "advance_gateway" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "${local.region}a"
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "${local.region}b"
}

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.128.0/18"
  map_public_ip_on_launch = false
  availability_zone       = "${local.region}b"
}


resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.advance_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet1_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_table.id
}

resource "aws_route_table_association" "public_subnet2_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_table.id
}

resource "aws_security_group" "advance_lb_sg" {
  name        = "AdvanceLoadBalancerSG"
  description = "Security group for the application load balancer"
  vpc_id      = aws_vpc.custom_vpc.id
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

resource "aws_security_group" "advance_service_sg" {
  name        = "AdvanceServiceSG"
  description = "Security group for the ECS service"
  vpc_id      = aws_vpc.custom_vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.advance_lb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "service_lb" {
  name                       = "AdvanceLoadBalancer"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups            = [aws_security_group.advance_lb_sg.id]
  enable_deletion_protection = false
  idle_timeout               = 60
}

resource "aws_lb_target_group" "advance_lb_target" {
  name        = "AdvanceLbTarget"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.custom_vpc.id
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-209"
  }
}


resource "aws_lb_listener" "advance_lb_listener" {
  load_balancer_arn = aws_alb.service_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.advance_lb_target.arn
  }
}

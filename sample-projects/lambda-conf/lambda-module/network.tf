
resource "aws_vpc" "simple" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}LamdaConfVpc"
  }
}

resource "aws_subnet" "simple" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.simple.id
  availability_zone = "eu-west-2b"

  tags = {
    Name = "${var.app_name}LambdaConfSubnet"
  }
}

resource "aws_security_group" "simple" {
  name_prefix = "lambda-conf"
  vpc_id      = aws_vpc.simple.id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

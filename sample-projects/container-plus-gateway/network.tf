resource "aws_vpc" "custom_vpc" {
  cidr_block           = local.vpc.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet_one" {
  vpc_id                  = aws.custom_vpc.id
  cidr_block              = local.public_one.cidr
  availability_zone       = local.zones[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_two" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.public_two.cidr
  availability_zone       = local.zones[1]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_three" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.public_three.cidr
  availability_zone       = local.zones[2]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_one" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.private_one.cidr
  availability_zone       = local.zones[0]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_two" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.private_two.cidr
  availability_zone       = local.zones[1]
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private_subnet_three" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = local.private_three.cidr
  availability_zone       = local.zones[2]
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "simple_gateway" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple_gateway.id
  }
  depends_on = [aws_internet_gateway.simple_gateway]
}

resource "aws_route_table_association" "public_subnet_one_assoc" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_one.id
}

resource "aws_route_table_association" "public_subnet_two_assoc" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_two.id
}

resource "aws_route_table_association" "public_subnet_three_assoc" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_three.id
}

resource "aws_eip" "elastic_ip_one" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.simple_gateway]
}

resource "aws_eip" "elastic_ip_two" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.simple_gateway]
}

resource "aws_eip" "elastic_ip_three" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.simple_gateway]
}

resource "aws_nat_gateway" "nat_gateway_one" {
  allocation_id     = aws_eip.elastic_ip_one.id
  subnet_id         = aws_subnet.public_subnet_one.id
  connectivity_type = "public"
}

resource "aws_nat_gateway" "nat_gateway_two" {
  allocation_id     = aws_eip.elastic_ip_two.id
  subnet_id         = aws_subnet.public_subnet_two.id
  connectivity_type = "public"
}

resource "aws_nat_gateway" "nat_gateway_three" {
  allocation_id     = aws_eip.elastic_ip_three.id
  subnet_id         = aws_subnet.public_subnet_three.id
  connectivity_type = "public"
}

resource "aws_route_table" "private_route_table_one" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_one.id
  }
}

resource "aws_route_table_association" "private_subnet_one_assoc" {
  route_table_id = aws_route_table.private_route_table_one.id
  subnet_id      = aws_subnet.private_subnet_one.id
}

resource "aws_route_table" "private_route_table_two" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_two.id
  }
}

resource "aws_route_table_association" "private_subnet_two_assoc" {
  route_table_id = aws_route_table.private_route_table_two.id
  subnet_id      = aws_subnet.private_subnet_two.id
}

resource "aws_route_table" "private_route_table_three" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_three.id
  }
}

resource "aws_route_table_association" "private_subnet_three_assoc" {
  route_table_id = aws_route_table.private_route_table_three.id
  subnet_id      = aws_subnet.private_subnet_three.id
}

resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id       = aws_vpc.custom_vpc.id
  service_name = "com.amazonaws.${local.region}.dynamodb"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      }
    ]
  })
  route_table_ids = [
    aws_route_table.private_route_table_one.id,
    aws_route_table.private_route_table_two.id,
    aws_route_table.private_route_table_three.id
  ]
}

resource "aws_security_group" "container_sg" {
  vpc_id      = aws_vpc.custom_vpc.id
  description = "Access to the Fargate containers"

  /* 
  * A security group self-ingress rule allows instances associated with the same 
  * security group to communicate with each other. Thi can be useful for allowing 
  * traffic within a group of instances without exposing then to the outside world.
  */
  ingress {
    description     = "Self ingress"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.container_sg.id]
  }
}

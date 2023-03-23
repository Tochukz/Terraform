resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Plus1Conf-${var.env_name}-VPC"
  }
}

resource "aws_internet_gateway" "custom_getway" {
  vpc_id = aws_vpc.custom_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.custom_vpc.id 
   cidr_block = "10.0.0.0/17"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"
  tags = {
    Name = "Plus1Conf-${var.env_name}-PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.custom_vpc.id 
  cidr_block = "10.0.128.0/18"
  map_public_ip_on_launch = false
   availability_zone = "${var.region}b"
  tags = {
    Name = "Plus1Conf-${var.env_name}-PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.custom_vpc.id
  cidr_block = "10.0.192.0/18"
  map_public_ip_on_launch = false
   availability_zone = "${var.region}c"
  tags = {
    Name = "Plus1Conf-${var.env_name}-PrivateSubnet2"
  }
}

resource "aws_security_group" "web_security_group" {
  vpc_id = aws_vpc.custom_vpc.id
  name = "Plus1Conf-${var.env_name}-Web-SG"
  description = "Allows incoming HTTP/HTTPS, SSH access and all outgoing requests"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming HTTP requests"
  }
  ingress {
    to_port = 443
    from_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming HTTPS requests"
  }
  ingress {
    from_port = 22
    to_port = 22 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all incoming SSH requests"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing requests of all kinds"
  }
  tags = {
    Name = "Plus1Conf-${var.env_name}-SecurityGroup"
  }
}

resource "aws_security_group" "db_security_group" {
  vpc_id = aws_vpc.custom_vpc.id
  name = "Plus1Conf-${var.env_name}-Db-SG"
  description = "Allows incoming request on port 5432"

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow access to requests from public subnet at port 5432"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_getway.id
  }
  tags = {
    Name = "Plus1Conf-${var.env_name}-PublicRouteTable"
  }
}

resource "aws_route_table_association" "subnet_public_table_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_network_interface" "custom_network_interface" {
  subnet_id = aws_subnet.private_subnet1.id
  security_groups = [ aws_security_group.web_security_group.id ]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_network_interface.custom_network_interface.id
  }
  tags ={
    Name = "Plus1Conf-${var.env_name}-PrivateRouteTable"
  }
}

resource "aws_route_table_association" "subnet_private_table_assoc" {
  subnet_id = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_route_table.id
}
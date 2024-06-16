/* The ECR Repository should be created before hand and populated with an image. 
*  This can be done with AWS CLI. See the readme file
resource "aws_ecr_repository" "express-repo" {
  name         = "express-repo"
  force_delete = true
}
*/
data "aws_iam_policy" "task_execution_policy" {
  name = "AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "task_execution_role" {
  name = "SimpleExecRole"
  assume_role_policy = jsonencode(({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  }))
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attach" {
  policy_arn = data.aws_iam_policy.task_execution_policy.arn
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_vpc" "simple_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.simple_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}


resource "aws_ecs_cluster" "simple_cluster" {
  name = "simple-cluster"
}

resource "aws_internet_gateway" "simple_gateway" {
  vpc_id = aws_vpc.simple_vpc.id
}

resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.simple_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.simple_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_table.id
}

resource "aws_ecs_task_definition" "simple_task" {
  family                   = "service"
  network_mode             = "awsvpc" # Fargate only supports awsvpc network mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "simple-task"
      image     = var.ecr_repository_url
      essential = true
      portMapping = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_security_group" "ecs_sec_group" {
  vpc_id = aws_vpc.simple_vpc.id

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

  tags = {
    Name = "ecs_security_group"
  }
}


resource "aws_ecs_service" "simple_service" {
  name            = "simple-service"
  cluster         = aws_ecs_cluster.simple_cluster.id
  task_definition = aws_ecs_task_definition.simple_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.ecs_sec_group.id]
    assign_public_ip = true
  }
}

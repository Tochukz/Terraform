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

resource "aws_ecs_cluster" "simple_cluster" {
  name = "simple-cluster"
}

resource "aws_ecs_task_definition" "simple_task" {
  family                   = "simple-express-family"
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
      environment = [
        {
          name  = "PORT"
          value = var.env_variables.PORT
        },
        {
          name  = "NODE_ENV"
          value = var.env_variables.NODE_ENV
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "simple_service" {
  name            = "simple-service"
  cluster         = aws_ecs_cluster.simple_cluster.id
  task_definition = aws_ecs_task_definition.simple_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  # force_new_deployment               = true
  # deployment_minimum_healthy_percent = 0 # May lead to downtime in deployment of new image
  network_configuration {
    subnets          = [aws_subnet.public_subnet.id]
    security_groups  = [aws_security_group.ecs_sec_group.id]
    assign_public_ip = true
  }
}

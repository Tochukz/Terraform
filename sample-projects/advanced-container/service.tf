resource "aws_ecr_repository" "simple_repo" {
  name         = "simple-express"
  force_delete = true
}

resource "aws_ecs_cluster" "simple_cluser" {
  name = "simple-express"
}

resource "aws_ecs_task_definition" "simple_task" {
  family = "simple-app-task"
  # container_definitions    = file("task-definitions.json")
  container_definitions = jsonencode([
    {
      name      = "simple-app-task"
      image     = "${aws_ecr_repository.simple_repo.repository_url}"
      essential = true
      portMappings = [
        {
          containerPort = 8083
          hostPort : 8083
        }
      ],
      memory = 512
      cpu    = 256
    }
  ])
  network_mode             = "awsvpc"    #  When networkMode=awsvpc, the host ports and container ports in port mappings must match.
  requires_compatibilities = ["FARGATE"] # Fargate only supports network mode ‘awsvpc’.
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "app_service" {
  name            = "SimpleAppService"
  cluster         = aws_ecs_cluster.simple_cluser.id
  task_definition = aws_ecs_task_definition.simple_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  load_balancer {
    target_group_arn = aws_lb_target_group.simple_lb_target.arn
    container_name   = aws_ecs_task_definition.simple_task.family
    container_port   = 8083
  }
  network_configuration {
    subnets          = [aws_default_subnet.subnet_a.id, aws_default_subnet.subnet_b.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.simple_service_sg.id]
  }
}

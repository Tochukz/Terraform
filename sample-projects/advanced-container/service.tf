/* The repository must be created before hand and an image must be uploaded to the repository
# resource "aws_ecr_repository" "advance_repo" {
#   name         = "advance-express"
#   force_delete = true
# }
*/

resource "aws_ecs_cluster" "advance_cluser" {
  name = "advance-cluster"
}

resource "aws_ecs_task_definition" "advance_task" {
  family                   = "advanced-express-family"
  network_mode             = "awsvpc"    #  When networkMode=awsvpc, the host ports and container ports in port mappings must match.
  requires_compatibilities = ["FARGATE"] # Fargate only supports network mode ‘awsvpc’.
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.ecr_repository_url
      # cpu       = 256
      # memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
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

resource "aws_ecs_service" "app_service" {
  name            = "advance-service"
  cluster         = aws_ecs_cluster.advance_cluser.id
  task_definition = aws_ecs_task_definition.advance_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  # force_new_deployment = true
  load_balancer {
    target_group_arn = aws_lb_target_group.advance_lb_target.arn
    container_name   = var.container_name
    container_port   = 80
  }
  network_configuration {
    subnets          = [aws_subnet.private_subnet1.id]
    assign_public_ip = false
    security_groups  = [aws_security_group.advance_service_sg.id]
  }
  depends_on = [aws_lb_listener.advance_lb_listener]
}

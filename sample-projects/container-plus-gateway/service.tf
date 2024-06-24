resource "aws_ecs_cluster" "simple_cluster" {
  name = "custom-cluster"
}

resource "aws_ecs_task_definition" "foodstore_task_definition" {
  family                   = "FoodstoreTasks"
  task_role_arn            = aws_iam_role.foodstore_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "FoodstoreContainer"
      image     = "simonepomata/ecsapi-demo-foodstore:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DynamoDBTable"
          value = aws_dynamodb_table.foodstore_dynamo.id
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "petstore_task_definition" {
  family                   = "PetstoreTask"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.petstore_task_role.arn
  container_definitions = jsonencode({
    name      = "PetstoreContainer"
    image     = "simonepomata/ecsapi-demo-petstore:latest"
    essential = true
    portMappings = [
      {
        containerPort = 8080
        protocol      = "tcp"
      }
    ]
    environment = [
      {
        name  = "DynamoDBTable"
        value = aws_dynamodb_table.petstore_dynamo.id
      }
    ]
  })
}

resource "aws_ecs_service" "foodstore_service" {
  name            = "FoodstoreService"
  cluster         = aws_ecs_cluster.simple_cluster.id
  task_definition = aws_ecs_task_definition.foodstore_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  service_registries {
    registry_arn = aws_service_discovery_service.foodstore_service_discovery.arn
    port         = 8080
  }
  network_configuration {
    subnets = [
      aws_subnet.private_subnet_one.id,
      aws_subnet.private_subnet_two.id,
      aws_subnet.public_subnet_three.id
    ]
    security_groups = [
      aws_security_group.container_sg.id
    ]
    assign_public_ip = false
  }
  depends_on = [
    aws_route_table.private_route_table_one,
    aws_route_table.private_route_table_two,
    aws_route_table.private_route_table_three
  ]
}

resource "aws_ecs_service" "petstore_service" {
  name            = "PetstoreService"
  cluster         = aws_ecs_cluster.simple_cluster.id
  task_definition = aws_ecs_task_definition.petstore_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  service_registries {
    registry_arn = aws_service_discovery_service.petstore_service_discovery.id
    port         = 8080
  }
  network_configuration {
    subnets = [
      aws_subnet.private_subnet_one.id,
      aws_subnet.private_subnet_two.id,
      aws_subnet.private_subnet_three.id
    ]
    security_groups = [
      aws_security_group.container_sg.id
    ]
    assign_public_ip = false
  }
  depends_on = [
    aws_route_table.private_route_table_one,
    aws_route_table.private_route_table_two,
    aws_route_table.private_route_table_three
  ]
}

resource "aws_appautoscaling_target" "foodstore_auto_scaling" {
  min_capacity       = var.min_containers_foodstore_foods
  max_capacity       = var.max_containers_foodstore_foods
  resource_id        = "/service/${aws_ecs_cluster.simple_cluster.name}/${aws_ecs_service.foodstore_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.auto_scaling_role.arn
}

resource "aws_appautoscaling_target" "petstore_auto_scaling" {
  min_capacity       = var.min_containers_petstore_pets
  max_capacity       = var.max_container_petstore_pets
  resource_id        = "/service/${aws_ecs_cluster.simple_cluster.name}/${aws_ecs_service.petstore_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.auto_scaling_role.arn
}

# resource "aws_appautoscaling_policy" "foodstore_scaling_policy" {
#   policy_name = "${aws_ecs_service.foodstore_service.name}-AutoScalingPolicy"
#   policy_type = "TargetTrackingScaling"
#   scaling_target_id = ""
# }

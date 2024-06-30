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
  container_definitions = jsonencode([
    {
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
    }
  ])
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
    registry_arn = aws_service_discovery_service.petstore_service_discovery.arn
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
  resource_id        = "service/${aws_ecs_cluster.simple_cluster.name}/${aws_ecs_service.foodstore_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.auto_scaling_role.arn
}

resource "aws_appautoscaling_target" "petstore_auto_scaling" {
  min_capacity       = var.min_containers_petstore_pets
  max_capacity       = var.max_container_petstore_pets
  resource_id        = "service/${aws_ecs_cluster.simple_cluster.name}/${aws_ecs_service.petstore_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.auto_scaling_role.arn
}

resource "aws_appautoscaling_policy" "foodstore_scaling_policy" {
  name               = "${aws_ecs_service.foodstore_service.name}-AutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.foodstore_auto_scaling.resource_id
  scalable_dimension = aws_appautoscaling_target.foodstore_auto_scaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.foodstore_auto_scaling.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.auto_scaling_target_value_foodstore_foods
  }
}

resource "aws_appautoscaling_policy" "petstore_scaling_policy" {
  name               = "${aws_ecs_service.petstore_service.name}-AutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.petstore_auto_scaling.resource_id
  scalable_dimension = aws_appautoscaling_target.petstore_auto_scaling.scalable_dimension
  service_namespace  = aws_appautoscaling_target.petstore_auto_scaling.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = var.auto_scaling_target_value_petstore_pets
  }
}

resource "aws_apigatewayv2_vpc_link" "api_vpc_link" {
  name = var.environment_name
  security_group_ids = [
    aws_security_group.container_sg.id
  ]
  subnet_ids = [
    aws_subnet.private_subnet_one.id,
    aws_subnet.private_subnet_two.id,
    aws_subnet.private_subnet_three.id
  ]
}

resource "aws_cognito_user_pool" "simple_user_pool" {
  name                     = "SimpleUserPool"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false
    required            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "simple_pool_client" {
  name                          = "SimplePoolClient"
  user_pool_id                  = aws_cognito_user_pool.simple_user_pool.id
  generate_secret               = false
  supported_identity_providers  = ["COGNITO"]
  prevent_user_existence_errors = "ENABLED"
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "SimpleHTTPApi"
  protocol_type = "HTTP"
  body = jsonencode(
    {
      openapi = "3.0.1"
      info = {
        title = var.environment_name,
      }
      components = {
        securitySchemas = {
          my-authorizer = {
            type  = "oauth2"
            flows = {}
          }
          x-amazon-apigateway-authorizer = {
            identitySource = "$request.header.Authorization"
            jwtConfiguration = {
              audience = [
                aws_cognito_user_pool_client.simple_pool_client.id
              ]
              issuer = "cognito-idp.${local.region}.amazonaws.com" # aws_cognito_user_pool.simple_user_pool.provider_url
            }
            type = "jet"
          }
        }
      }
      paths = {
        "/foodstore/foods/{foodId}" = {
          get = {
            responses = {
              default = {
                description = "Default response for GET /foodstore/foods/{foodId}",
              }
            }
            x-amazon-apigateway-integration = {
              payloadFormatVersion = "1.0"
              connectionId         = aws_apigatewayv2_vpc_link.api_vpc_link.id
              type                 = "http_proxy"
              httpMethod           = "ANY"
              uri                  = aws_service_discovery_service.foodstore_service_discovery.arn
              connectionType       = "VPC_LINK"
            }
          }
          put = {
            responses = {
              default = {
                description = "Default response for PUT /foodstore/foods/{foodId}"
              }
            }
            security = [
              # my-authorizer = []
            ]
            x-amazon-apigateway-integration = {
              payloadFormatVersion = "1.0"
              connectionId         = aws_apigatewayv2_vpc_link.api_vpc_link.id
              type                 = "http_proxy"
              httpMethod           = "ANY"
              uri                  = aws_service_discovery_service.foodstore_service_discovery.arn
              connectionType       = "VPC_LINK"
            }
          }
        }
        "/petstore/pets/{petId}" = {
          get = {
            responses = {
              default = {
                description = "Default response for GET /petstore/pets/{petId}"
              }
            }
            x-amazon-apigateway-integration = {
              payloadFormatVersion = "1.0"
              connectionId         = aws_apigatewayv2_vpc_link.api_vpc_link.id
              type                 = "http_proxy"
              httpMethod           = "ANY"
              uri                  = aws_service_discovery_service.petstore_service_discovery.arn
              connectionType       = "VPC_LINK"
            }
          }
          put = {
            responses = {
              default = {
                description = "Default response for PUT /petstore/pets/{petId}"
              }
            }
            security = [
              # my-authorizer = []
            ]
            x-amazon-apigateway-integration = {
              payloadFormatVersion = "1.0"
              connectionId         = aws_apigatewayv2_vpc_link.api_vpc_link.id
              type                 = "http_proxy"
              httpMethod           = "ANY"
              uri                  = aws_service_discovery_service.petstore_service_discovery.arn
              connectionType       = "VPC_LINK"
            }
          }
        }
      }
      x-amazon-apigateway-cors = {
        # @todo: Change this to your own origin
        allowOrigins = [
          "https://master.d34am23lsz3nvz.amplifyapp.com"
        ]
        allowHeaders = ["*"]
        allowMethods = ["PUT", "GET"]
      }
      x-amazon-apigateway-importexport-version = "1.0"
    }
  )
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  name        = "$default"
  api_id      = aws_apigatewayv2_api.http_api.id
  auto_deploy = true
}

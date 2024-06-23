resource "aws_ecs_cluster" "simple_cluster" {
  name = "custom-cluster"
}

resource "aws_ecs_task_definition" "foodstore_task_definition" {
  family                   = "FoodStoreTasks"
  task_role_arn            = aws_iam_role.foodstore_task_role.arn
  requires_compatibilities = "FARGATE"
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

# resource "aws_ecs_task_definition" "petstore_task_definition" {

# }

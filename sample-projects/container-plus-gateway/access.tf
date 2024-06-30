resource "aws_iam_role" "auto_scaling_role" {
  name = "AutoScalingRole"
  assume_role_policy = jsonencode({
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
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
  ]
}

resource "aws_iam_role" "ecs_role" {
  name = "ECS_Role"
  assume_role_policy = jsonencode(({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  }))
  path = "/"
}

resource "aws_iam_policy" "ecs_policy" {
  name = "ECS_Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:Describe*",
          "ec2:DetachNetworkInterface",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_role_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ECS_TaskExecutionRole"
  assume_role_policy = jsonencode({
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
  })
  path = "/"
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "ECS_TaskExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}

resource "aws_iam_role" "foodstore_task_role" {
  name = "FoodstoreTaskRole"
  assume_role_policy = jsonencode({
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
  })
}

resource "aws_iam_policy" "foodstore_task_policy" {
  name = "FoodstoreTaskPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem",
        ]
        Resource = aws_dynamodb_table.foodstore_dynamo.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "foodstore_task_role_attach" {
  role       = aws_iam_role.foodstore_task_role.name
  policy_arn = aws_iam_policy.foodstore_task_policy.arn
}

resource "aws_iam_role" "petstore_task_role" {
  name = "PetstoreTaskRole"
  assume_role_policy = jsonencode({
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
  })
}
resource "aws_iam_policy" "petstore_task_policy" {
  name = "PetstoreTaskPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem",
        ]
        Resource = [
          aws_dynamodb_table.petstore_dynamo.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "petstore_task_role_attach" {
  role       = aws_iam_role.petstore_task_role.name
  policy_arn = aws_iam_policy.petstore_task_policy.arn
}

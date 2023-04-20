terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "xyz.tochukwu-terraform-states"
    key    = "lambda-conf/terraform.tfstate.json"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

variable "app_version" {
  description = "The version of the application build"
  default     = "1.0.0"
}

resource "aws_vpc" "lambda_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "LamdaConfVpc"
  }
}

resource "aws_subnet" "lambda_subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.lambda_vpc.id
  availability_zone = "eu-west-2b"

  tags = {
    Name = "LambdaConfSubnet"
  }
}

resource "aws_security_group" "lambda_security_group" {
  name_prefix = "lambda-conf"
  vpc_id      = aws_vpc.lambda_vpc.id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}


resource "aws_lambda_function" "lambda_func" {
  function_name = "lambda-func-app"

  #   filename =  "main.zip"
  #   source_code_hash = filebase64sha256("main.zip")
  s3_bucket = "tochukwu1-bucket"
  s3_key    = "v${var.app_version}/main.zip"

  handler = "main.handler"
  role    = aws_iam_role.lambda_role.arn
  runtime = "nodejs18.x"
  vpc_config {
    subnet_ids         = [aws_subnet.lambda_subnet.id]
    security_group_ids = [aws_security_group.lambda_security_group.id]
  }
}

resource "aws_api_gateway_rest_api" "lambda_rest_api" {
  name        = "LambdaRestAPI"
  description = "Lambda Rest API Configuration"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_rest_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_rest_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda_rest_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_func.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_rest_api.id
  resource_id   = aws_api_gateway_rest_api.lambda_rest_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.lambda_rest_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_func.invoke_arn
}

resource "aws_api_gateway_deployment" "simple" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root
  ]
  rest_api_id = aws_api_gateway_rest_api.lambda_rest_api.id
  stage_name  = "develop"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_rest_api.execution_arn}/*/*"
}


resource "aws_api_gateway_account" "simple" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "cloudwatch-global"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy" "cloudwatch" {
  name = "cloudwatch_default"
  role = aws_iam_role.cloudwatch.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_api_gateway_stage" "simple" {
  deployment_id = aws_api_gateway_deployment.simple.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_rest_api.id
  stage_name    = "simple"
}

resource "aws_api_gateway_method_settings" "general_settings" {
  rest_api_id = aws_api_gateway_rest_api.lambda_rest_api.id
  # stage_name  = aws_api_gateway_deployment.simple.stage_name
  stage_name  = aws_api_gateway_stage.simple.stage_name
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

output "base_url" {
  value = aws_api_gateway_deployment.simple.invoke_url
}

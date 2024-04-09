data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "laravel_lambda_role" {
  name = "LaravelLambdaRole"
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

resource "aws_iam_policy" "laravel_lambda_policy" {
  name = "LaravelLambdaPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.laravel_lambda.function_name}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  policy_arn = aws_iam_policy.laravel_lambda_policy.arn
  role       = aws_iam_role.laravel_lambda_role.name
}

/*
resource "aws_lambda_layer_version" "laravel_layer" {
  layer_name          = "LaravelLambdaLayer"
  s3_bucket           = "local-dev-workspace"
  s3_key              = "v0.0.1/php-vendor.zip"
  compatible_runtimes = ["provided.al2"]
}
*/

resource "aws_lambda_function" "laravel_lambda" {
  function_name = "Laravel_App"
  timeout       = 120
  runtime       = "provided.al2"
  s3_bucket     = "local-dev-workspace"
  s3_key        = "v0.0.6/laravel-app.zip"
  handler       = "public/index.php"
  role          = aws_iam_role.laravel_lambda_role.arn
  memory_size   = 1024
  environment {
    variables = {
      APP_NAME    = "LaravelApp"
      APP_ENV     = "development"
      APP_KEY     = var.app_key
      DB_HOST     = var.db_host
      DB_PORT     = 3306
      DB_DATABASE = var.db_name
      DB_USERNAME = var.db_user
      DB_PASSWORD = var.db_pass
    }
  }
  layers = [
    "arn:aws:lambda:eu-west-2:534081306603:layer:php-83-fpm:21", # See https://runtimes.bref.sh/
    # "${aws_lambda_layer_version.laravel_layer.layer_arn}:${var.layer_version}"
  ]
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_function_url" "app_url" {
  function_name      = aws_lambda_function.laravel_lambda.function_name
  authorization_type = "NONE"
  depends_on = [
    aws_lambda_function.laravel_lambda
  ]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "simple_lambda_role" {
  name = "SimpleLambdaRole"
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

resource "aws_iam_policy" "simple_lambda_policy" {
  name = "SimpleLambdaPolicy"
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
          "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.simple_lambda.function_name}:*"
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
  policy_arn = aws_iam_policy.simple_lambda_policy.arn
  role       = aws_iam_role.simple_lambda_role.name
}

resource "aws_lambda_function" "simple_lambda" {
  function_name = "Simple_PHP"
  timeout       = 120
  runtime       = "provided.al2"
  s3_bucket     = "local-dev-workspace"
  s3_key        = "v0.0.1/sample-php.zip"
  handler       = "index.php"
  role          = aws_iam_role.simple_lambda_role.arn
  memory_size   = 1024
  environment {
    variables = {
      ENV = "development"
    }
  }
  layers = [
    "arn:aws:lambda:eu-west-2:534081306603:layer:php-83:21" # See https://runtimes.bref.sh/
  ]
  tracing_config {
    mode = "Active"
  }
}

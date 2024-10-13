resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExeuctionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# To learn more about the AWSLambdaBasicExecutionRole manageed policy 
# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html

resource "aws_lambda_layer_version" "shared_layer" {
  layer_name          = "SharedLayer"
  compatible_runtimes = ["nodejs20.x"]
  s3_bucket           = var.arctifact_bucket
  s3_key              = "${var.artifact_version}/shared-module.zip"
}

resource "aws_lambda_function" "user_mgt" {
  function_name = "UserManagement"
  handler       = "lambda.handler"
  runtime       = "nodejs20.x"
  memory_size   = 512
  timeout       = 15
  role          = aws_iam_role.lambda_execution_role.arn
  s3_bucket     = var.arctifact_bucket
  s3_key        = "${var.artifact_version}/user-management.zip"
  layers = [
    aws_lambda_layer_version.shared_layer.arn
  ]
}

resource "aws_lambda_function" "catalog_mgt" {
  function_name = "CatalogManagement"
  handler       = "lambda.handler"
  runtime       = "nodejs20.x"
  memory_size   = 512
  timeout       = 15
  role          = aws_iam_role.lambda_execution_role.arn
  s3_bucket     = var.arctifact_bucket
  s3_key        = "${var.artifact_version}/catalog-management.zip"
  layers = [
    aws_lambda_layer_version.shared_layer.arn
  ]
}

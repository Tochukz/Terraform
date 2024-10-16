resource "aws_lambda_function" "service_lambda" {
  function_name = var.function_name 
  handler       = "lambda.handler"
  runtime       = "nodejs20.x"
  memory_size   = 512
  timeout       = 15
  role          = var.role_arn
  s3_bucket     = var.artifact_bucket
  s3_key        = var.artifact_key
  layers = var.layer_arns
}
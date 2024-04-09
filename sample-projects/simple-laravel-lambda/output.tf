output "lambda_endpoint" {
  value = aws_lambda_function_url.app_url.function_url
}

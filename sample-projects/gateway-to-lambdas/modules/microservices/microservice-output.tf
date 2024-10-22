output "api_gateway_endpoint" {
  value = aws_api_gateway_deployment.simple_deployment.invoke_url
}
output "base_url" {
  value = aws_api_gateway_deployment.simple.invoke_url
}

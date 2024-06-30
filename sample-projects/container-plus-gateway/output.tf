output "api_invoke_url" {
  value = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${local.region}.amazonaws.com"
}
output "api_invoke_url_foodstore" {
  value = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${local.region}.amazonaws.com/foodstore/foods/{foodId}"
}
output "api_invoke_url_petstore" {
  value = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${local.region}.amazonaws.com/petstore/pets/{petId}"
}
output "api_id" {
  value = aws_apigatewayv2_api.http_api.id
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.simple_cluster.name
}
output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}
output "container_security_group" {
  value = aws_security_group.container_sg.id
}
output "private_dns_namespace" {
  value = aws_service_discovery_private_dns_namespace.private_namespace.id
}

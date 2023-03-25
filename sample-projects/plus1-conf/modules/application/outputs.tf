output "cognito_userpool_id" {
  value = aws_cognito_user_pool.cognito_userpool.id
}
output "cognito_client_id" {
  value = aws_cognito_user_pool_client.cognito_client.id
}
output "codedeploy_app_name" {
  value = aws_codedeploy_app.codedeploy_app.name
}
output "deployment_group_names" {
  value = [ aws_codedeploy_deployment_group.codedeploy_group.*.id]
}
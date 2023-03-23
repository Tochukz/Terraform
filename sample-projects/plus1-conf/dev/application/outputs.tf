output "cognito_userpool_id" {
  value = module.application.cognito_userpool_id
}
output "cognito_client_id" {
  value = module.application.cognito_client_id
}
output "codedeploy_app_id" {
  value = module.application.codedeploy_app_id
}
output "deployment_group_ids" {
  value = module.application.deployment_group_ids
}
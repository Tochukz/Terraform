data "aws_iam_policy_document" "assumed_role" {
  statement {
    effect = "Allow" 
    principals {
      type = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

locals {
  deploy_group_names = [
    "plus1conf-${var.env_name}-API1-DpGp", 
    "plus1conf-${var.env_name}-API2-DpGp"
  ]
}

resource "aws_cognito_user_pool" "cognito_userpool" {
  name = "plus1conf-${var.env_name}-userpool"
}

resource "aws_cognito_user_pool_client" "cognito_client" {
  name = "plus1conf-${var.env_name}-userpool-client"
  user_pool_id = aws_cognito_user_pool.cognito_userpool.id
}

resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Server"
  name = "plus1conf-${var.env_name}-codedeploy-app"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "plus1conf-${var.env_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assumed_role.json
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role = aws_iam_role.codedeploy_role.name
}

resource "aws_codedeploy_deployment_group" "codedeploy_group" {
  app_name = aws_codedeploy_app.codedeploy_app.name
  service_role_arn = aws_iam_role.codedeploy_role.arn
  count = length(local.deploy_group_names)
  deployment_group_name = element(local.deploy_group_names, count.index)
}
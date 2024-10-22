locals {
  prefixes = {
    dev     = "Dev"
    staging = "Staging"
    prod    = "Prod"
  }
}

resource "aws_api_gateway_rest_api" "simple_gateway" {
  name        = "${local.prefixes[var.env]}_SimpleAPI"
  description = "Gateway for for online store services"
}


resource "aws_iam_role" "gateway_execution_role" {
  name = "${local.prefixes[var.env]}GatewayExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gateway_policy_attach" {
  role       = aws_iam_role.gateway_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
# To learn more about the AmazonAPIGatewayPushToCloudWatchLogs managed policy 
# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonAPIGatewayPushToCloudWatchLogs.html


module "catalog_gateway_resource" {
  source            = "../../submodules/gateway-resource"
  path_path         = "product"
  rest_api_id       = aws_api_gateway_rest_api.simple_gateway.id
  root_resource_id  = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  lambda_func_name  = module.catalog_mgt_lambda.function_name
  lambda_invoke_arn = module.catalog_mgt_lambda.invoke_arn
  execution_arn     = aws_api_gateway_rest_api.simple_gateway.execution_arn
}

module "user_gateway_resource" {
  source            = "../../submodules/gateway-resource"
  path_path         = "user"
  rest_api_id       = aws_api_gateway_rest_api.simple_gateway.id
  root_resource_id  = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  lambda_func_name  = module.user_mgt_lambda.function_name
  lambda_invoke_arn = module.user_mgt_lambda.invoke_arn
  execution_arn     = aws_api_gateway_rest_api.simple_gateway.execution_arn
}

resource "aws_api_gateway_deployment" "simple_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  stage_name  = var.stage_name
  depends_on = [
    module.catalog_gateway_resource,
    module.user_gateway_resource,
    # The aws_api_gateway_deployment resource depends on aws_api_gateway_integration which is defined in the gateway-resource submodules
  ]
}

resource "aws_cloudwatch_log_group" "simple_log_group" {
  name              = "/aws/api-gateway/GatewayToLambdas_${local.prefixes[var.env]}"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "simple_account" {
  cloudwatch_role_arn = aws_iam_role.gateway_execution_role.arn
}

resource "aws_api_gateway_stage" "simple_stage" {
  rest_api_id   = aws_api_gateway_rest_api.simple_gateway.id
  deployment_id = aws_api_gateway_deployment.simple_deployment.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.simple_log_group.arn
    format = jsonencode({
      requestId      = "$context.requestId",
      ip             = "$context.identity.sourceIp",
      caller         = "$context.identity.caller",
      user           = "$context.identity.user",
      requestTime    = "$context.requestTime",
      httpMethod     = "$context.httpMethod",
      resourcePath   = "$context.resourcePath",
      status         = "$context.status",
      protocol       = "$context.protocol",
      responseLength = "$context.responseLength"
    })
  }
  xray_tracing_enabled = true
  depends_on           = [aws_api_gateway_account.simple_account]
}



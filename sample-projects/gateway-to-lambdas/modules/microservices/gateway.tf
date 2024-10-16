locals {
  prefixes = {
    dev = "Dev"
    staging = "Staging"
    prod = "Prod"
  }
}

resource "aws_api_gateway_rest_api" "simple_gateway" {
  name        = "${local.prefixes[var.env]}_SimpleAPI"
  description = "Gateway for for online store services"
}


module "catalog_gateway_resource" {
  source = "../../submodules/gateway-resource"
  path_path = "product"
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  root_resource_id = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  lambda_func_name = module.catalog_mgt_lambda.function_name 
  lambda_invoke_arn = module.catalog_mgt_lambda.invoke_arn 
  execution_arn = aws_api_gateway_rest_api.simple_gateway.execution_arn
}

module "user_gateway_resource" {
  source = "../../submodules/gateway-resource"
  path_path = "user"
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  root_resource_id = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  lambda_func_name = module.user_mgt_lambda.function_name 
  lambda_invoke_arn = module.user_mgt_lambda.invoke_arn 
  execution_arn = aws_api_gateway_rest_api.simple_gateway.execution_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  stage_name  = var.stage_name
  depends_on = [
    module.catalog_gateway_resource,
    module.user_gateway_resource,
    # The aws_api_gateway_deployment resource depends on aws_api_gateway_integration which is defined in the gateway-resource submodules
  ]
}

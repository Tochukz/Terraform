locals {
  services = {
    product = "Catalog"
    user = "User"
  }
}

resource "aws_api_gateway_resource" "service_resource" {
  rest_api_id = var.rest_api_id #aws_api_gateway_rest_api.simple_gateway.id
  parent_id   = var.root_resource_id # aws_api_gateway_rest_api.simple_gateway.root_resource_id
  path_part   = var.path_path
}

resource "aws_api_gateway_resource" "service_proxy_resource" {
  rest_api_id = var.rest_api_id # aws_api_gateway_rest_api.simple_gateway.id
  parent_id   = aws_api_gateway_resource.service_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "service_proxy_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.service_proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "catalog_proxy_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.service_proxy_resource.id
  http_method             = aws_api_gateway_method.service_proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn # aws_lambda_function.catalog_mgt.invoke_arn
   request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_lambda_permission" "service_mgt_permission" {
  statement_id  = "AllowAPIGatewayInvoke${local.services[var.path_path]}Mgt"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_func_name # aws_lambda_function.catalog_mgt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.execution_arn}/*/*"
}
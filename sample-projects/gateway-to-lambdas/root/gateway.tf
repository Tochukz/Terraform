resource "aws_api_gateway_rest_api" "simple_gateway" {
  name        = "SimpleAPI"
  description = "Gateway for for online store services"
}


resource "aws_api_gateway_resource" "user_resource" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  parent_id   = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "user_method" {
  rest_api_id   = aws_api_gateway_rest_api.simple_gateway.id
  resource_id   = aws_api_gateway_resource.user_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.simple_gateway.id
  resource_id             = aws_api_gateway_resource.user_resource.id
  http_method             = aws_api_gateway_method.user_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_mgt.invoke_arn
}

resource "aws_lambda_permission" "users_mgt_permission" {
  statement_id  = "AllowAPIGatewayInvokeUserMgt"
  action        = "lambda:InvokeFuncion"
  function_name = aws_lambda_function.user_mgt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.simple_gateway.execution_arn}/*/*"
}


resource "aws_api_gateway_resource" "catalog_resource" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  parent_id   = aws_api_gateway_rest_api.simple_gateway.root_resource_id
  path_part   = "product"
}

resource "aws_api_gateway_resource" "catalog_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  parent_id   = aws_api_gateway_resource.catalog_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "catalog_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.simple_gateway.id
  resource_id   = aws_api_gateway_resource.catalog_proxy_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "catalog_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.simple_gateway.id
  resource_id             = aws_api_gateway_resource.catalog_proxy_resource.id
  http_method             = aws_api_gateway_method.catalog_proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.catalog_mgt.invoke_arn
}

resource "aws_lambda_permission" "catalog_mgt_permission" {
  statement_id  = "AllowAPIGatewayInvokeCatalogMgt"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catalog_mgt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.simple_gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.simple_gateway.id
  stage_name  = var.stage_name
  depends_on = [
    aws_api_gateway_integration.user_integration,
    aws_api_gateway_integration.catalog_proxy_integration
  ]
}

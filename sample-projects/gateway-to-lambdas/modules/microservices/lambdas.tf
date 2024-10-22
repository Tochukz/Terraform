
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.prefixes[var.env]}LambdaExeuctionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# To learn more about the AWSLambdaBasicExecutionRole managed policy 
# see https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSLambdaBasicExecutionRole.html

resource "aws_lambda_layer_version" "shared_layer" {
  layer_name          = "${local.prefixes[var.env]}SharedLayer"
  compatible_runtimes = ["nodejs20.x"]
  s3_bucket           = var.artifact_bucket
  s3_key              = "${var.artifact_version}/shared-module.zip"
}

module "user_mgt_lambda" {
  source          = "../../submodules/lambda"
  function_name   = "${local.prefixes[var.env]}UserManagement"
  artifact_bucket = var.artifact_bucket
  artifact_key    = "${var.artifact_version}/user-management.zip"
  role_arn        = aws_iam_role.lambda_execution_role.arn
  layer_arns = [
    "${aws_lambda_layer_version.shared_layer.layer_arn}:${var.layer_version}"
  ]
}


module "catalog_mgt_lambda" {
  source          = "../../submodules/lambda"
  function_name   = "${local.prefixes[var.env]}CatalogManagement"
  artifact_bucket = var.artifact_bucket
  artifact_key    = "${var.artifact_version}/catalog-management.zip"
  role_arn        = aws_iam_role.lambda_execution_role.arn
  layer_arns = [
    "${aws_lambda_layer_version.shared_layer.layer_arn}:${var.layer_version}"
  ]
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.app_name}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}


resource "aws_lambda_function" "simple" {
  function_name = "${var.app_name}_LambdaFuncApp"

  #   filename =  "main.zip"
  #   source_code_hash = filebase64sha256("main.zip")
  s3_bucket = "tochukwu1-bucket"
  s3_key    = "v${var.app_version}/${var.build_name}.zip"

  handler = var.handler
  role    = aws_iam_role.lambda_role.arn
  runtime = "nodejs18.x"
  vpc_config {
    subnet_ids         = [aws_subnet.simple.id]
    security_group_ids = [aws_security_group.simple.id]
  }
}

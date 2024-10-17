resource "aws_iam_policy" "devops_deploy" {
  name = "DevOps_Deploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3PutDeleteFrontendAssets"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "*" # ARN of the S3 bucket for the frontend assets
      },
      {
        Sid    = "S3PutGetForLambdaPackage"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:CreateMultipartUpload",
          "s3:GetObject"
        ]
        Resource = "*" # ARN of the S3 bucket for the lambda code package
      },
      {
        Sid    = "S3ListFrontendAssets"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "*" # ARN of the S3 bucket for the frontend assets
      },
      {
        Sid    = "CloudfrontCreateInvalidation"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*" # ARN of the cloudfront distribution 
      },
      {
        Sid    = "KmsDecryptS3Objects"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = "*"
      },
      {
        Sid    = "LambdaUpdateInvoke"
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:InvokeFunction"
        ]
        Resource = "*" # ARN of the lambda function 
      },
      {
        Sid    = "LambdaLayerGetPublish"
        Effect = "Allow"
        Action = [
          "lambda:PublishLayerVersion",
          "lambda:GetLayerVersion"
        ]
        Resource = "*" # ARN of the lambda function layer
      },
      {
        Sid      = "EcsAllowDescribeUpdate",
        Effect   = "Allow"
        Action   = ["ecs:DescribeServices", "ecs:UpdateService"],
        Resource = "*" # ARN of the ECS services
      },
      {
        Sid    = "EcrGetAuthToken",
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",

          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:ListImages",
        ],
        Resource = "*" # ARN of the ECR repository
      },
    ]
  })
  tags = {
    Description = "IAM policy for backend deployment pipeline"
  }
}


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
        Sid    = "EcrRepositoryDeploy",
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
      {
        Sid    = "CloudformationForServelessFrameworkCli"
        Effect = "Allow"
        Action = [
          "cloudformation:DescribeStackResource"
        ]
        Resource = "arn:aws:cloudformation:${local.region}:${local.account_id}:*/*/*"
      },
    ]
  })
  tags = {
    Description = "IAM policy for CI/CD deployment pipeline"
  }
}

resource "aws_iam_policy" "serverless_deploy" {
  name = "Serverless_Deploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "IamForServerlessCli"
        Effect   = "Allow"
        Action   = ["iam:GetRole", "iam:PassRole"]
        Resource = "*"
      },
      {
        Sid      = "SsmForServerlessCli"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = "*"
      },
      {
        Sid    = "LambdaForServerlessCli"
        Effect = "Allow"
        Action = [
          "lambda:Get*",
          "lambda:List",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:CreateAlias",
          "lambda:DeleteAlias",
          "lambda:UpdateAlias",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:InvokeFunction",
          "lambda:PublishVersion",
          "lambda:ListTags",
          "lambda:ListVersionsByFunction",
        ]
        Resource = "*"
      },
      {
        Sid    = "LambdaLayerForServerlessCli"
        Effect = "Allow"
        Action = [
          "lambda:PublishLayerVersion"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ListForServerlessCli"
        Effect = "Allow"
        Action = [
          "s3:List*",
        ]
        Resource = "*"
      },
      {
        Sid    = "S3CreateForServerlessCli"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:GetBucketLocation",
          "s3:DeleteBucket",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudformationValidateForServerlessCli"
        Effect = "Allow"
        Action = [
          "cloudformation:ValidateTemplate"
        ],
        Resource = "*"
      },
      {
        Sid    = "CloudformationCreateForServerlessCli"
        Effect = "Allow"
        Action = [
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStackResources",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:ListStackResources",
          "cloudformation:SetStackPolicy",
          "cloudformation:UpdateStack",
          "cloudformation:UpdateTerminationProtection",
          "cloudformation:GetTemplate"
        ]
        Resource = "*"
      }
    ]
  })
}


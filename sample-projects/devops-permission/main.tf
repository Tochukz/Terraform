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
        Sid      = "EcrAuthorization",
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Sid    = "EcrPublish",
        Effect = "Allow"
        Action = [
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
    Statement : [
      {
        Sid      = "StsForServerlessCli",
        Effect   = "Allow",
        Action   = ["sts:GetCallerIdentity"]
        Resource = "*",
      },
      {
        Sid    = "IamForServerlessCli",
        Effect = "Allow",
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "iam:TagRole",
        ],
        Resource = "*",
      },
      {
        Sid      = "SsmAllForServerlessCli",
        Effect   = "Allow",
        Action   = ["ssm:PutParameter", "ssm:GetParameter"],
        Resource = "*",
      },
      {
        Sid    = "ApiGatwayForServerlessCli",
        Effect = "Allow",
        Action = [
          "apigateway:DeleteRestApi",
          "apigateway:DeleteResource",
          "apigateway:DeleteRequestValidator",
          "apigateway:DeleteMethod",
          "apigateway:DeleteDeployment",
          "apigateway:CreateDeployment",
          "apigateway:PutMethod",
          "apigateway:PutIntegration",
          "apigateway:PutMethodResponse",
          "apigateway:PutIntegrationResponse",
          "apigateway:CreateResource",
          "apigateway:CreateRequestValidator",
          "apigateway:CreateRestApi",
          "apigateway:GetDeployment",
          "apigateway:GetStage",
          "apigateway:GetMethod",
          "apigateway:GetRequestValidator",
          "apigateway:GetRestApi",
          "apigateway:PUT",
          "apigateway:POST",
          "apigateway:GET",
          "apigateway:DELETE",
        ],
        Resource = "*",
      },
      {
        Sid    = "LambdaForServerlessCli",
        Effect = "Allow",
        Action = [
          "lambda:GetFunction",
          "lambda:ListLayers",
          "lambda:ListLayerVersions",
          "lambda:ListFunctions",
          "lambda:GetLayerVersion",
          "lambda:CreateFunction",
          "lambda:InvokeFunction",
          "lambda:PublishLayerVersion",
          "lambda:PublishVersion",
          "lambda:PutFunctionEventInvokeConfig",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:AddLayerVersionPermission",
          "lambda:AddPermission",
          "lambda:DeleteFunction",
          "lambda:ListTags",
          "lambda:TagResource",
          "lambda:UntagResource",
          "lambda:ListVersionsByFunction",
          "lambda:RemovePermission",
          "lambda:DeleteLayerVersion",
        ],
        Resource = "*",
      },
      {
        Sid    = "S3AllForServerlessCli",
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketVersioning",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteBucket",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:GetEncryptionConfiguration",
          "s3:PutEncryptionConfiguration",
          "s3:ListBucketVersions",
        ],
        Resource = "*",
      },
      {
        Sid    = "LogsForServerlessCli",
        Effect = "Allow",
        Action = [
          "logs:DeleteLogGroup",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:TagResource",
        ],
        Resource = "*",
      },
      {
        Sid    = "CloudformationForServerlessCli",
        Effect = "Allow",
        Action = [
          "cloudformation:UpdateStack",
          "cloudformation:Validate*",
          "cloudformation:Start*",
          "cloudformation:Continue*",
          "cloudformation:RollbackStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:CreateStack",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:ListStackResources",
          "cloudformation:SetStackPolicy",
          "cloudformation:GetTemplate",
          "cloudformation:ValidateTemplate",
        ],
        Resource = "*",
      },
    ],
  })
}


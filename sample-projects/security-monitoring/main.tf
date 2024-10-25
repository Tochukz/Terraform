data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

locals {
  trail_name = "SimpleSecTrail"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  partition  = data.aws_partition.current.partition
}

resource "aws_iam_role" "cloudtrail_role" {
  name = "SimpleCloudTrailRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "SimpleClouTrailPolicy"
  description = "Policy for CloudTrail to put logs in CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
      }
    ]
  })
}

resource "aws_sns_topic" "cloudtrail_notification" {
  name = "CloudTrailNotification"
}

resource "aws_sns_topic_subscription" "notification_subscription" {
  topic_arn = aws_sns_topic.cloudtrail_notification.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_iam_role_policy_attachment" "cloud_policy_attach" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = aws_iam_policy.cloudtrail_policy.arn
}

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "/aws/cloudtrail/SimpleCloudTrailLogs"
  retention_in_days = 90
}

resource "aws_s3_bucket" "cloudtrail_log_storage" {
  bucket        = "simple-cloudtrail-logs"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail_storage_policy" {
  bucket = aws_s3_bucket.cloudtrail_log_storage.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = ["s3:GetBucketAcl"]
        Resource = aws_s3_bucket.cloudtrail_log_storage.arn
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.cloudtrail_log_storage.arn}/AWSLogs/${local.account_id}/CloudTrail/*"
        #Resource = "${aws_s3_bucket.cloudtrail_log_storage.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:${local.partition}:cloudtrail:${local.region}:${local.account_id}:trail/${local.trail_name}"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "simple_trail" {
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_log_storage.bucket
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail_log_group.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  # depends_on                    = [aws_s3_bucket_policy.cloudtrail_storage_policy]
}

resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "UnAuthorizedApiCall"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"
  metric_transformation {
    name      = "UnauthorizedApiCalls"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_alarm" {
  alarm_name          = "UnAuthorizedApiAlarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.unauthorized_api_calls.metric_transformation[0].namespace
  statistic           = "Sum"
  period              = 300
  alarm_actions = [
    aws_sns_topic.cloudtrail_notification.arn
  ]
}

resource "aws_cloudwatch_log_metric_filter" "root_login" {
  name           = "RootLoginAttempt"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  # pattern        = "{ ($.userIdentity.type = \"Root\") && ($.userIdentity.invokedBy NOT EXISTS) && ($.eventType = \"AwsConsoleLogin\") }"
  pattern = "{ $.userIdentity.type = Root }"
  metric_transformation {
    name      = "RootLoginAttempts"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_login_alarm" {
  alarm_name          = "RootLoginAlarm"
  alarm_description   = "This alarm triggers when there is a root login attempt."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  metric_name         = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.root_login.metric_transformation[0].namespace
  statistic           = "Sum"
  period              = 300
  alarm_actions = [
    aws_sns_topic.cloudtrail_notification.arn
  ]
}

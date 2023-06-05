data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy_doc" {
  statement {
    effect = "Allow"
    action = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords"
    ]
    resources = "*"
  }
  statement {
    effect = "Allow"
    action  = [
      "dynamodb:BatchGetItem",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:Query",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:ConditionCheckItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [
      aws_dynamo_db_table.stable_table.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      aws_dynamo_db_table.config_table.arn
      aws_dynamo_db_table.maintenance_window_table.arn
    ]
  }
  statement {
    effect = "Allow" 
    actions = [
      "ssm:PutParameter",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:${local.partition}:ssm:${local.region}:${local.account_id}:parameter/Solutions/aws-instance-scheduler/UUID/*" 
    ]
  }
}

locals {
  partition = data.aws_partition.current.partition
  region = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  timeouts = {
    1 = "cron(0/1 * * * ? *)"
    2 = "cron(0/2 * * * ? *)"
    5 = "cron(0/5 * * * ? *)"
    10 = "cron(0/10 * * * ? *)"
    15 = "cron(0/15 * * * ? *)"
    30 = "cron(0/30 * * * ? *)"
    60 = "cron(0 0/1 * * ? *)"
  }
}

resource "aws_cloudwatch_log_group" "simple" {
  name = "scheduler-${var.namespace}-logs"
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "simple" {
  name = "${var.namespace}-role"
  assume_role_policy = jsonencode({
    Version: "2012-10-17"
     Statement=  [
      {
       Action: "sts:AssumeRole",
       Effect: "Allow",
       Principal: {
         Service: "events.amazonaws.com"
       }
      },
      {
       Action: "sts:AssumeRole",
       Effect: "Allow",
       Principal: {
         Service: "lambda.amazonaws.com"
       }
      }
     ],     
  })
}

resource aws_iam_policy "scheduler_role_policy" {
  name = "scheduler-${var.namespace}-role-policy"
  policy = data.aws_iam_policy_document.policy_doc.json
}
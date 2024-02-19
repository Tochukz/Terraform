terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_cloudwatch_metric_alarm" "budget_alarm" {
  alarm_name                = "BudgetAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  period                    = 21600 # 6 Hours
  statistic                 = "Maximum"
  threshold                 = 80
  alarm_description         = "This metric monitors budget"
  insufficient_data_actions = []

  dimensions = {

  }
  alarm_actions = []
}

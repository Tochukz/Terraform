terraform {
  required_version = ">= 1.5.5"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

data "aws_iam_policy_document" "topic_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.simple_topic.arn]
  }
}

resource "aws_cloudwatch_event_bus" "simple_bus" {
  name = "simple-bus"
}

resource "aws_cloudwatch_event_rule" "ec2_statechange_rule" {
  name = "ec2-statechange-rule"
  description = "Events for EC2 instance state change"
  event_pattern = file("ec2-pattern.json")
  event_bus_name = aws_cloudwatch_event_bus.simple_bus.arn
}

resource "aws_cloudwatch_event_target" "sns_target" {
  name = "sns-target"
  target_id = "Simple_SNS_Target"
  arn = aws_sns_topic.simple_topic.arn
  depends_on = [ aws_sns_topic.simple_topic.arn ]
}

resource "aws_sns_topic" "simple_topic" {
  name = "simple-sns-topic"
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn    = aws_sns_topic.simple_topic.arn
  policy = data.aws_iam_policy_document.topic_policy_document.json
}


resource "aws_sns_topic" "deployment_begins" {
  name = "plus1conf-${var.env_name}-deployment-begins-topic"
  fifo_topic = false
  content_based_deduplication = false
}

resource "aws_sns_topic" "deployment_ends" {
  name = "plus1conf-${var.env_name}-deployment-end-topic"
  fifo_topic = false
  content_based_deduplication = false
}

resource "aws_sqs_queue" "dead_deployment_queue" {
  name = "plus1conf-${var.env_name}-dead-deployment-queue"
}

resource "aws_sqs_queue" "deployment_queue" {
  name = "plus1conf-${var.env_name}-deployment-queue"
  delay_seconds = 30 
  max_message_size = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_deployment_queue.arn
    maxReceiveCount = 4
  })
  tags = {
    Environment = var.env_name
  }
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.deployment_begins.arn 
  protocol = "sqs" 
  endpoint = aws_sqs_queue.deployment_queue.arn
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.deployment_begins.arn
  protocol = "email"
  endpoint = var.subscribe_email 
}

resource "aws_sns_topic_subscription" "http_subscription" {
 topic_arn = aws_sns_topic.deployment_begins.arn 
 protocol = "https"
 endpoint = var.subscribe_endpoint
}
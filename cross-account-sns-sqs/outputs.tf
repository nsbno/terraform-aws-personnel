output "sqs" {
  default = aws_sqs_queue.app_sqs
}

output "topic_subscription" {
  default = aws_sns_topic_subscription.sqs_subscription
}

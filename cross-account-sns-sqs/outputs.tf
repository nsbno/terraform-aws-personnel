output "sqs" {
  value = aws_sqs_queue.app_sqs
}

output "topic_subscription" {
  value = aws_sns_topic_subscription.sqs_subscription
}

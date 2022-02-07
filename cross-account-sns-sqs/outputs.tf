variable "sqs" {
  default = aws_sqs_queue.app_sqs
}

variable "topic_subscription" {
  default = aws_sns_topic_subscription.sqs_subscription
}

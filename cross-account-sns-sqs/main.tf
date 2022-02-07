###########################################################
# Cross account SNS-subscription for SNS-SQS-fanout pattern
# 1. Create and allow the SQS queue to subscribe to a SNS-topic
# 2. Allow SNS to sendMessage to the SQS queue
# 3. (Optional) Sets IAM-user-policy to interact with the SQS and SNS
############################################################

data "aws_iam_policy_document" "sqs_write_for_sns" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["sns.amazonaws.com"]
      type        = "Service"
    }
    actions = ["SQS:SendMessage"]
    resources = [aws_sqs_queue.app_sqs.arn]
  }
}

data "aws_iam_policy_document" "subscribe_policy" {
  statement {
    effect = "Allow"
    actions = ["SNS:Subscribe"]
    resources = [var.sns_arn]
  }
}

data "aws_iam_policy_document" "allow_user_sqs_actions" {
  statement {
    effect = "Allow"
    actions = [
      "SQS:SendMessage",
      "SQS:GetQueueAttributes",
      "SQS:GetQueueUrl",
      "SQS:DeleteMessageBatch",
      "SQS:PurgeQueue",
      "SQS:ReceiveMessage",
      "SQS:DeleteMessage",
      "SQS:ListQueues"
    ]
    resources = [aws_sqs_queue.app_sqs.arn]
  }
}

resource "aws_sqs_queue" "app_sqs" {
  name                       = "${var.name_prefix}-${var.name_sqs}"
  delay_seconds              = 0
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 60
  max_message_size           = 262144
  message_retention_seconds  = 86400
  fifo_queue                 = false
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = var.sns_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.app_sqs.arn
  filter_policy = var.filter_policy
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  policy = data.aws_iam_policy_document.sqs_write_for_sns.json
  queue_url = aws_sqs_queue.app_sqs.id
}

resource "aws_iam_user_policy" "subscribe_to_sns_policy" {
  count = var.ext_username == "" ? 0 : 1
  name = "allow_sns_cross_account_subscription"
  policy = data.aws_iam_policy_document.subscribe_policy.json
  user = var.ext_username
}

resource "aws_iam_user_policy" "allow_user_sqs_operations" {
  count = var.ext_username == "" ? 0 : 1
  name = "allow_sqs_operations_cross_account_subscription"
  policy = data.aws_iam_policy_document.allow_user_sqs_actions.json
  user = var.ext_username
}

variable "sns_arn" {
  description = "The ARN for the SNS-topic that the created SQS should subscribe to. If Account A is subscribing to a topic in Account B, account B must give Account A account wide root permission"
  type        = string
}

variable "name_prefix" {
  description = "A prefix used for naming resources after domain-name."
  type        = string
}

variable "name_sqs" {
  description = "Name suffix of sqs queue."
  type        = string
}

variable "ext_username" {
  description = "Name of an external IAM user to be given SQS and SNS-subscription permissions. (Optional)"
  type       = string
  default    = ""
}

variable "filter_policy" {
  description = "(OPTIONAL) A filter policy applied for the SNS-SQS-subscription. i.e JSON-encoded map"
  default = "{}"
}

output "name" {
  description = "The name of the IAM user."
  value       = aws_iam_user.ext_user.name
}

output "arn" {
  description = "The ARN of the IAM user."
  value       = aws_iam_user.ext_user.arn
}
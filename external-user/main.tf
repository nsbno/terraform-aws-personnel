resource "aws_iam_user" "ext_user" {
  name = "${var.name_prefix}-ext_user"
}

resource "aws_iam_access_key" "ext_user" {
  user = aws_iam_user.ext_user.name
}

resource "aws_ssm_parameter" "ext_user_access_key_id" {
  name   = format("%s%s", var.ssm_prefix == "" ? "" : "${var.ssm_prefix}/", "${var.name_prefix}-ext-user-access-key-id")
  type   = "SecureString"
  value  = aws_iam_access_key.ext_user.id
  key_id = var.user_parameters_key
}

resource "aws_ssm_parameter" "ext_user_secret_key" {
  name   = format("%s%s", var.ssm_prefix == "" ? "" : "${var.ssm_prefix}/", "${var.name_prefix}-ext-user-secret-key")
  type   = "SecureString"
  value  = aws_iam_access_key.ext_user.secret
  key_id = var.user_parameters_key
}
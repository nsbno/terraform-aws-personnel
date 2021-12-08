variable "name_prefix" {
  description = "A prefix used for naming resources."
  type = string
}
variable "ssm_prefix" {
  description = "(Optional) An SSM prefix to use for the parameters containing the IAM user's access keys (e.g., `/<name-prefix>/<application-name>`)."
  default     = ""
}

variable "user_parameters_key" {
  default = ""
}
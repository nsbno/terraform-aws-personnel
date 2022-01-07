variable "cognito_central_user_pool_id" {
  description = ""
}
variable "cognito_central_account_id" {
  description = ""
}
variable "tags" {
  default = {}
}
variable "current_region" {
  default = "eu-west-1"
}
variable "create_app_client" {
  default = true
}
variable "cognito_central_enable" {
  default = true
}
variable "app_client_scopes" {
  default = []
}
variable "cognito_central_bucket" {
  description = "(Optional) Configure where to upload delegated cognito config. Default is vydev-delegated-cognito-staging."
  type        = string
  default     = "vydev-delegated-cognito-staging"
}
variable "cognito_central_env" {
  default = ""
}
variable "environment" {
  description = "Name of the environment, Ex. dev, test ,stage, prod."
  type        = string
}
variable "default_production_environment" {
  default = "prod"
}
variable "name_prefix" {
  description = ""
}
variable "service_name" {
  description = ""
}

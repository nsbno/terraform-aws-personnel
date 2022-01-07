###########################################################
# App Client in the central Cognito
#
# We need to create appClients such that on-premise apps can
# get OAuth tokens for our services in AWS
###########################################################
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  current_account_id         = data.aws_caller_identity.this.account_id
  current_region             = data.aws_region.this.name
  name_prefix                = var.name_prefix
  application_name           = var.service_name
  environment                = var.environment
  central_cognito_account_id = var.cognito_central_account_id
  central_cognito_bucket     = var.cognito_central_bucket
  central_cognito_secret_id  = "arn:aws:secretsmanager:${local.current_region}:${local.central_cognito_account_id}:secret:${local.current_account_id}-${local.name_prefix}-${local.application_name}-id"
}

resource "aws_s3_bucket_object" "delegated-cognito-config" {
  bucket = local.central_cognito_bucket
  key    = "${local.environment}/${local.current_account_id}/${local.name_prefix}-${local.application_name}.json"
  acl    = "bucket-owner-full-control"
  content = jsonencode({
    user_pool_client = {
      name_prefix     = "${local.name_prefix}-${local.application_name}"
      generate_secret = true

      explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
      allowed_oauth_flows = ["client_credentials"]
      allowed_oauth_scopes = var.app_client_scopes
      allowed_oauth_flows_user_pool_client = true
    }
  })
  content_type = "application/json"
}

##
# Read Credentials from Secrets Manager and set in microservice SSM config.
# Store the md5 of the cognito config so that a change in md5/config
# Will trigger a new update on dependent resources.
#
# Using workaround using time_sleep for async pipeline in cognito to complete
# configuration of resource server and application client in delegated cognito.
# The sleep wait will only occur when the dependent S3 file is updated
# and during normal operation without changes it will not pause here.
resource "time_sleep" "wait_for_credentials" {
  count = (var.cognito_central_enable && var.create_app_client) ? 1 : 0
  create_duration = "300s"

  triggers = {
    config_hash = sha1(aws_s3_bucket_object.delegated-cognito-config.content)
  }
}

# The client credentials that are stored in Central Cognito.
data "aws_secretsmanager_secret_version" "microservice_client_credentials" {
  depends_on = [aws_s3_bucket_object.delegated-cognito-config, time_sleep.wait_for_credentials[0]]
  count = (var.cognito_central_enable && var.create_app_client) ? 1 : 0
  secret_id = local.central_cognito_secret_id
}

# Store client credentials from Central Cognito in SSM so that the microservice can read it.
resource "aws_ssm_parameter" "central_client_id" {
  count = (var.cognito_central_enable && var.create_app_client) ? 1 : 0
  name      =  "/${var.name_prefix}/external/app/${var.service_name}/cognito.clientId"
  type      = "SecureString"
  value     = jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_id"]
  overwrite = true

  # store the hash as a tag to establish a dependency to the wait_for_credentials resource
  tags      = merge(var.tags, {
    config_hash: time_sleep.wait_for_credentials[0].triggers.config_hash
  })
}

# Store client credentials from Central Cognito in SSM so that the microservice can read it.
resource "aws_ssm_parameter" "central_client_secret" {
  count = (var.cognito_central_enable && var.create_app_client) ? 1 : 0
  name      =  "/${var.name_prefix}/external/app/${var.service_name}/cognito.clientSecret"
  type      = "SecureString"
  value     =  jsondecode(data.aws_secretsmanager_secret_version.microservice_client_credentials[0].secret_string)["client_secret"]
  overwrite = true

  # store the hash as a tag to establish a dependency to the wait_for_credentials resource
  tags      = merge(var.tags, {
    config_hash: time_sleep.wait_for_credentials[0].triggers.config_hash
  })
}

locals {
  cognito_env = "${length(var.cognito_central_env) > 0 ? var.cognito_central_env : var.environment}"
  central_cognito_url = "https://auth.${var.default_production_environment == local.cognito_env ? "" : "${local.cognito_env}."}cognito.vydev.io"
}

# SSM Parameters to configure the cognito endpoint url for microservice when requesting
# access tokens from Cognito to communicate with other services.
resource "aws_ssm_parameter" "central_cognito_url" {
  count = (var.cognito_central_enable && var.create_app_client) ? 1 : 0
  name  = "/${var.name_prefix}/external/app/${var.service_name}/cognito.url"
  type  = "String"

  # store the hash as a tag to establish a dependency to the wait_for_credentials resource
  tags      = merge(var.tags, {
    config_hash: time_sleep.wait_for_credentials[0].triggers.config_hash
  })

  # Use default environment, or overridden cognito environment.
  value = local.central_cognito_url
  overwrite = true
}

# SSM Parameters to configure the cognito endpoint jwks url to the microservice.
# used to verify the signature in the received access token.
# See the configuration of the jwt token verification in the microservice application-cloud.yml
# for how this is configured for each microservice.
resource "aws_ssm_parameter" "central_cognito_jwks_url" {
  count = var.cognito_central_enable ? 1 : 0
  name  = "/${var.name_prefix}/external/app/${var.service_name}/jwksUrl"
  type  = "String"
  tags      = var.tags

  # Use default environment, or overridden cognito environment.
  value = "https://cognito-idp.${var.current_region}.amazonaws.com/${var.cognito_central_user_pool_id}/.well-known/jwks.json"
  overwrite = true
}
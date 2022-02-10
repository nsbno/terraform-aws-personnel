# terraform-aws-personnel
Collection of terraform modules created by Team Personnel


### External user
Create an IAM-user. The users access_key and secret_key are put in SSM-parameter store.

<details>
  <summary>Example</summary>

```terraform
module "example-user" {
  source = "github.com/nsbno/terraform-aws-personnel?ref=d1c2000/external-user"
  
  name_prefix = "example-user"
  ssm_prefix = "/external/user"
}
```
</details>

### Cross-account sns to sqs subscription


<details>
  <summary>Example</summary>

```terraform
  
module "example-user" {
  source = "github.com/nsbno/terraform-aws-personnel?ref=d1c2000/external-user"
  
  name_prefix = "example-user"
  ssm_prefix = "/external/user"
}

module "example_queue" {
  source = "github.com/nsbno/terraform-aws-personnel?ref=9bf51ee/cross-account-sns-sqs"
  sns_arn = "arn:for:cross:account:topic"
  name_prefix = "example_name_prefix"
  name_sqs = "insert_cool_sqs_name"
  ext_username = module.example-user.name // This is optional
}
```
</details>

### External app client

Create an app-client in central cognito for on-premise application integration. This app-client
can be used for on-premise apps to get OAuth-tokens.

This creates an appClient that can use an `clientId` and a `clientSecret` for the client_credentials Oauth2 flow.

The id and secret can be found in SSM-parameter-store at the following location in a given AWS-account.

- `/team_context_name/external/app/example-name/cognito.clientId`
- `/team_context_name/external/app/example-name/cognito.clientSecret`
- `/team_context_name/external/app/example-name/cognito.url`
- `/team_context_name/external/app/example-name/jwksUrl`

<details>
  <summary>Example</summary>

```terraform
module "app" {
  source = "github.com/nsbno/terraform-aws-personnel?ref=db719c8/external-app-client"
  
  cognito_central_user_pool_id = "eu-west-1_0AvVv5Wyk" // cognito-dev-pool
  cognito_central_account_id = "834626710667" // cognito-dev

  environment = "dev" // dev, test, stage, prod
  name_prefix = "team_context_name" // i.e. (personnel, control, gui, infrastructure) 
  service_name = "example-name"
  
  app_client_scopes = [
    "https://services.<env>.<team_context_name>.vydev.io/<app>/read", // i.e https://services.personnel.vydev.io/trainstaff/get.duties (prod)
    "https://services.<env>.<team_context_name>.vydev.io/<app>/write", // i.e. https://services.test.trafficinfo.vydev.io/trainroute/train/nominalDate
    "https://services.<env>.<team_context_name>.vydev.io/<app>/update" // i.e. https://services.stage.trafficgui.vydev.io/hello/update
  ]
}
```
</details>



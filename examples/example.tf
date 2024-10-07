provider "aws" {
  region = "us-east-1"
}

module "cognito" {
  source = "./../"

  name        = "cognito"
  environment = "test"
  label_order = ["environment", "name"]

  enabled                  = true
  advanced_security_mode   = "OFF"
  domain                   = "clouddrove"
  mfa_configuration        = "ON"
  allow_software_mfa_token = true
  email_subject            = "Sign up for <project_name>."

  users = {
    user01 = {
      email = "test01@test.com"
    }
    user02 = {
      email = "test02@test.com"
    }
  }

  user_groups = [
    {
      name        = "test_group"
      description = "This is test group."
    }
  ]

  resource_servers = [
    {
      name       = "test-pool Resource"
      identifier = "test-pool"
      scope = [
        {
          scope_name        = "read"
          scope_description = "can read test-pool data"
        },
        {
          scope_name        = "write"
          scope_description = "can add or change test-pool data"
        }
      ]
    }
  ]

  clients = [
    {
      name                                 = "test-client"
      callback_urls                        = ["https://test.com/signinurl"]
      generate_secret                      = true
      logout_urls                          = []
      refresh_token_validity               = 30
      allowed_oauth_flows_user_pool_client = false
      supported_identity_providers         = ["COGNITO"]
      allowed_oauth_scopes                 = ["email", "openid", "profile", "phone"]
      allowed_oauth_flows                  = ["code"]
    },
    {
      name                                 = "test-client-2"
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = ["email", "openid", "phone", "test-pool/read", "test-pool/write"]
      callback_urls                        = ["https://localhost:3000", "https://localhost:8080"]
      explicit_auth_flows                  = ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
      generate_secret                      = true
      logout_urls                          = []
      access_token_validity                = 30
      id_token_validity                    = 30
      refresh_token_validity               = 30
      supported_identity_providers         = ["COGNITO"]
      prevent_user_existence_errors        = "ENABLED"
      enable_token_revocation              = true
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
    }
  ]
}

provider "aws" {
  region = "us-east-1"
}

module "cognito" {
  source = "./../"

  name        = "cognito"
  environment = "test"
  label_order = ["environment", "name"]

  enabled = true
  allow_admin_create_user_only          = false
  advanced_security_mode                = "OFF"
  domain                                = "test"
  mfa_configuration                     = "ON"
  allow_software_mfa_token              = true  
  deletion_protection                   = "INACTIVE"
  users = {
            user01 = {
              email = "test01@test.com"
            }
            user02 = {
              email = "test02@test.com"
            }
          }
  user_groups = [
          { name                              = "test_group"
            description                       = "This is test group."
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
    }
  ]
}
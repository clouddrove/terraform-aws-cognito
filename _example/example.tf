provider "aws" {
  region = "us-east-1"
}

module "cognito" {
  source = "./../"

  name        = "test-user"
  environment = "test"
  label_order = ["environment", "name"]

  enabled = true
  allow_admin_create_user_only          = false
  advanced_security_mode                = "OFF"
  domain                                = "test-domain"
  software_token_enabled                = false
  mfa_configuration                     = "OFF"
  deletion_protection                   = "INACTIVE"
  users = {
                test1 = {
                  email = "test1@stackx.cloud"
                }
                test2 = {
                  email = "test2@stackx.cloud"
                }
          }
  user_groups = [
          { name                              = "test_group_1"
            description                       = ""
          },
          { name                              = "test_group_2"
            description                       = ""
          },
          { name                              = "test_group_3"
            description                       = ""
          }
      ]

  clients = [
    {
      name                                 = "client_name_1"
      callback_urls                        = [""]
      generate_secret                      = true
      logout_urls                          = []
      refresh_token_validity               = 30
      allowed_oauth_flows_user_pool_client = false
      supported_identity_providers         = ["COGNITO"]
      allowed_oauth_scopes                 = ["email", "openid", "profile", "phone"]
      allowed_oauth_flows                  = ["code"]
    },
    {
      name                                 = "client-name_2"
      callback_urls                        = [""]
      logout_urls                          = []
      generate_secret                      = true
      logout_urls                          = []
      refresh_token_validity               = 30
      allowed_oauth_flows_user_pool_client = false
      supported_identity_providers         = ["COGNITO"]
      allowed_oauth_scopes                 = ["email", "openid", "profile", "phone"]
      allowed_oauth_flows                  = ["code"]
    },
  ]
  
  client_read_attributes                    = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]
  client_write_attributes                   = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "updated_at", "website", "zoneinfo"]     
}
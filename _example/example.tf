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
  domain                                = ""
  mfa_configuration                     = "OFF"
  deletion_protection                   = "INACTIVE"
  users = {
            rbuijs = {
              email = "r.buijs@i-sc.com"
            }
            rzeldent = {
              email = "r.zeldenthuis@i-sc.com"
            }
            vaibhav = {
              email = "pendharevaibhav@gmail.com"
            }
          }
  user_groups = [
          { name                              = "AMS"
            description                       = ""
          },
          { name                              = "BOG"
            description                       = ""
          },
          { name                              = "CUN"
            description                       = ""
          },
          { name                              = "HND"
            description                       = ""
          },
          { name                              = "ICN"
            description                       = ""
          },
          { name                              = "MBJ"
            description                       = ""
          },
          { name                              = "PUJ"
            description                       = ""
          },
          { name                              = "PVR"
            description                       = ""
          },
          { name                              = "SXM"
            description                       = ""
          }
      ]

  clients = [
    {
      name                                 = "xhrf-reporting"
      callback_urls                        = ["https://reporting.sandbox.x-check.net"]
      generate_secret                      = true
      logout_urls                          = []
      refresh_token_validity               = 30
      allowed_oauth_flows_user_pool_client = false
      supported_identity_providers         = ["COGNITO"]
      allowed_oauth_scopes                 = ["email", "openid", "profile", "phone"]
      allowed_oauth_flows                  = ["code"]
    },
    {
      name                                 = "xhrf-maintenance"
      callback_urls                        = ["https://maintenance.sandbox.x-check.net"]
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
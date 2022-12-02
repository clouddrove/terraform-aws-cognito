provider "aws" {
  region = "eu-west-1"
}

module "cognito" {
  source = "./../"

  name        = "cognito"
  environment = "test"
  label_order = ["environment", "name"]

  enabled = true
  allow_admin_create_user_only          = false
  advanced_security_mode                = "ENFORCED"
  cognito_domain                        = "test"
  region                                = "eu-west-1"
  software_token_enabled                = true
  mfa_configuration                     = "ON"
  
}
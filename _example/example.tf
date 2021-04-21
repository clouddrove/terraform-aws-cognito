provider "aws" {
  region = "eu-west-1"
}

module "cognito-ex" {
  source = "./../"

  name        = "cognito"
  environment = "test"
  label_order = ["environment", "name"]

  enabled = true
  cognito_domain = "cd-es-cog"
  region = "eu-west-1"
  software_token_enabled = false
}
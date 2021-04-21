variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "attributes" {
  type        = list
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `organization`, `environment`, `name` and `attributes`."
}

variable "tags" {
  type        = map
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "managedby" {
  type        = string
  default     = "anmol@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove' or 'AnmolNagpal'."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the cognito creation."
}

variable "repository" {
  type        = string
  default     = "https://registry.terraform.io/modules/clouddrove/cognito/aws/"
  description = "Terraform current module repo"
}

variable "alias_attributes" {
  type        = list
  default     = []
  description = "Attributes supported as an alias for this user pool. Valid values: phone_number, email, or preferred_username. Conflicts with username_attributes."
}

variable "auto_verified_attributes" {
  type        = list
  default     = ["email"]
  description = "Attributes to be auto-verified. Valid values: email, phone_number."
}

variable "username_attributes" {
  type        = list
  default     = ["email"]
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias_attributes."
}

variable "mfa_configuration" {
  type        = string
  default     = "OFF"
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool. Defaults of OFF. Valid values are OFF, ON and OPTIONAL."
}

variable "minimum_length" {
  type        = number
  default     = 8
  description = "Minimum length of the password policy that you have set."
}

variable "require_lowercase" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one lowercase letter in their password."
}

variable "software_token_enabled" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one lowercase letter in their password."
}

variable "case_sensitive" {
  type        = bool
  default     = true
  description = "Whether username case sensitivity will be applied for all users in the user pool through Cognito APIs."
}

variable "require_numbers" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one number in their password."
}

variable "require_symbols" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one symbol in their password."
}

variable "require_uppercase" {
  type        = bool
  default     = true
  description = "Whether you have required users to use at least one uppercase letter in their password."
}

variable "temporary_password_validity_days" {
  type        = number
  default     = 90
  description = "In the password policy you have set, refers to the number of days a temporary password is valid."
}

variable "advanced_security_mode" {
  type        = string
  default     = "OFF"
  description = "Mode for advanced security, must be one of OFF, AUDIT or ENFORCED."
}

variable "sms_authentication_message" {
  type        = string
  default     = "Your code is {####}"
  description = "String representing the SMS authentication message. The Message must contain the {####} placeholder, which will be replaced with the code."
}

variable "external_id" {
  type        = string
  default     = ""
  description = "External ID used in IAM role trust relationships."
}

variable "sns_caller_arn" {
  type        = string
  default     = ""
  description = "ARN of the Amazon SNS caller. This is usually the IAM role that you've given Cognito permission to assume."
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "The ARN of an ISSUED ACM certificate in us-east-1 for a custom domain."
}

variable "cognito_domain" {}
variable "region" {}

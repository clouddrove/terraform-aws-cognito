#Module      : LABEL
#Description : Terraform label module variables.
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

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-vpc"
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the cognito creation."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

#Module      : User Pool
#Description : 

variable "alias_attributes" {
  type        = list(any)
  default     = []
  description = "Attributes supported as an alias for this user pool. Valid values: phone_number, email, or preferred_username. Conflicts with username_attributes."
}

variable "auto_verified_attributes" {
  type        = list(any)
  default     = ["email"]
  description = "Attributes to be auto-verified. Valid values: email, phone_number."
}

variable "username_attributes" {
  type        = list(any)
  default     = ["email"]
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with alias_attributes."
}

variable "mfa_configuration" {
  type        = string
  default     = "OFF"
  description = "Multi-Factor Authentication (MFA) configuration for the User Pool. Defaults of OFF. Valid values are OFF, ON and OPTIONAL."
}

variable "advanced_security_mode" {
  type        = string
  default     = "OFF"
  description = "Mode for advanced security, must be one of OFF, AUDIT or ENFORCED."
}

variable "sms_authentication_message" {
  type        = string
  default     = "Your username is {username}. Sign up at {####}"
  description = "String representing the SMS authentication message. The Message must contain the {####} placeholder, which will be replaced with the code."
}

variable "case_sensitive" {
  type        = bool
  default     = true
  description = "Whether username case sensitivity will be applied for all users in the user pool through Cognito APIs."
}

################################################
## Admin Create USer
################################################

#### Password

variable "allow_admin_create_user_only" {
  type        = bool
  description = "(Optional) Set to True if only the administrator is allowed to create user profiles. Set to False if users can sign themselves up via an app."
  default     = true
}

variable "minimum_length" {
  type        = number
  description = "(Optional) The minimum length of the password policy that you have set."
  default     = 12
}

variable "require_lowercase" {
  type        = bool
  description = "(Optional) Whether you have required users to use at least one lowercase letter in their password."
  default     = true
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
  description = "(Optional) In the password policy you have set, refers to the number of days a temporary password is valid. If the user does not sign-in during this time, their password will need to be reset by an administrator."
  default     = 1
}

#### Lambda

variable "lambda_create_auth_challenge" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda creating an authentication challenge."
  default     = null
}

variable "lambda_custom_message" {
  type        = string
  description = "(Optional) The ARN of a custom message AWS Lambda trigger."
  default     = null
}

variable "lambda_define_auth_challenge" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that defines the authentication challenge."
  default     = null
}

variable "lambda_post_authentication" {
  type        = string
  description = "(Optional) The ARN of a post-authentication AWS Lambda trigger."
  default     = null
}

variable "lambda_post_confirmation" {
  type        = string
  description = "(Optional) The ARN of a post-confirmation AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_authentication" {
  type        = string
  description = "(Optional) The ARN of a pre-authentication AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_sign_up" {
  type        = string
  description = "(Optional) The ARN of a pre-registration AWS Lambda trigger."
  default     = null
}

variable "lambda_pre_token_generation" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that allows customization of identity token claims before token generation."
  default     = null
}

variable "lambda_user_migration" {
  type        = string
  description = "(Optional) The ARN of the user migration AWS Lambda config type."
  default     = null
}

variable "lambda_verify_auth_challenge_response" {
  type        = string
  description = "(Optional) The ARN of an AWS Lambda that verifies the authentication challenge response."
  default     = null
}

## Schema Atribute

variable "schema_attributes" {
  description = "(Optional) A list of schema attributes of a user pool. You can add a maximum of 25 custom attributes."
  type        = any

  # Example:
  #
  # schema_attributes = [
  #   {
  #     name                     = "alternative_name"
  #     type                     = "String"
  #     developer_only_attribute = false,
  #     mutable                  = true,
  #     required                 = false,
  #     min_length               = 0,
  #     max_length               = 2048
  #   },
  #   {
  #     name      = "friends_count"
  #     type      = "Number"
  #     min_value = 0,
  #     max_value = 100
  #
  #    },
  #    {
  #
  #      name = "is_active"
  #      type = "Boolean"
  #
  #    },
  #    {
  #      name = "last_seen"
  #      type = "DateTime"
  #
  #    }
  #  ]

  default = []
}



#########################################################################################################################################
### Client
#########################################################################################################################################

variable "client_allowed_oauth_flows" {
  description = "(Optional) List of allowed OAuth flows. Possible flows are 'code', 'implicit', and 'client_credentials'."
  type        = list(string)
  default     = null
}

variable "client_allowed_oauth_flows_user_pool_client" {
  description = "(Optional) Whether the client is allowed to follow the OAuth protocol when interacting with Cognito User Pools."
  type        = bool
  default     = null
}

variable "client_allowed_oauth_scopes" {
  description = "(Optional) List of allowed OAuth scopes. Possible values are 'phone', 'email', 'openid', 'profile', and 'aws.cognito.signin.user.admin'."
  type        = list(string)
  default     = null
}

variable "client_callback_urls" {
  description = "(Optional) List of allowed callback URLs for the identity providers."
  type        = list(string)
  default     = null
}

variable "client_default_redirect_uri" {
  description = "(Optional) The default redirect URI. Must be in the list of callback URLs."
  type        = string
  default     = null
}

variable "client_explicit_auth_flows" {
  description = "(Optional) List of authentication flows. Possible values are 'ADMIN_NO_SRP_AUTH', 'CUSTOM_AUTH_FLOW_ONLY', 'USER_PASSWORD_AUTH', 'ALLOW_ADMIN_USER_PASSWORD_AUTH', 'ALLOW_CUSTOM_AUTH', 'ALLOW_USER_PASSWORD_AUTH', 'ALLOW_USER_SRP_AUTH', and 'ALLOW_REFRESH_TOKEN_AUTH'."
  type        = list(string)
  default     = null
}

variable "client_generate_secret" {
  description = "Should an application secret be generated"
  type        = bool
  default     = true
}


variable "client_logout_urls" {
  description = "(Optional) List of allowed logout URLs for the identity providers."
  type        = list(string)
  default     = null
}

variable "client_read_attributes" {
  description = "(Optional) List of Cognito User Pool attributes the application client can read from."
  type        = list(string)
  default     = null
}

variable "client_refresh_token_validity" {
  description = "(Optional) The time limit in days refresh tokens are valid for."
  type        = number
  default     = 30
}

variable "client_prevent_user_existence_errors" {
  description = "(Optional) Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the Cognito User Pool. When set to 'ENABLED' and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to 'LEGACY', those APIs will return a 'UserNotFoundException' exception if the user does not exist in the Cognito User Pool."
  type        = string
  default     = null
}

variable "client_supported_identity_providers" {
  description = "(Optional) List of provider names for the identity providers that are supported on this client."
  type        = list(string)
  default     = null
}

variable "identity_providers" {
  description = "Cognito Pool Identity Providers"
  type        = list(any)
  default     = []
  sensitive   = true
}

variable "client_write_attributes" {
  description = "(Optional) List of Cognito User Pool attributes the application client can write to."
  type        = list(string)
  default     = null
}

variable "client_access_token_validity" {
  description = "(Optional) Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used. This value will be overridden if you have entered a value in 'default_client_token_validity_units'."
  type        = number
  default     = null
}

variable "client_id_token_validity" {
  description = "(Optional) Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. This value will be overridden if you have entered a value in 'default_client_token_validity_units'."
  type        = number
  default     = null
}

variable "client_token_validity_units" {
  description = "(Optional) Configuration block for units in which the validity times are represented in."
  type        = any
  default     = null
}

variable "client_enable_token_revocation" {
  description = "(Optional) Enables or disables token revocation."
  type        = bool
  default     = null
}

variable "client_name" {
  description = "The name of the application client"
  type        = string
  default     = null
}

variable "clients" {
  description = "A container with the clients definitions"
  type        = any
  default     = []
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}

#########################################################################################################################################
### Domain
#########################################################################################################################################

variable "domain" {
  description = "Cognito User Pool domain"
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "The ARN of an ISSUED ACM certificate in us-east-1 for a custom domain"
  type        = string
  default     = null
}

#########################################################################################################################################
### User Group
#########################################################################################################################################

variable "user_group_name" {
  description = "The name of the user group"
  type        = string
  default     = null
}

variable "user_group_description" {
  description = "The description of the user group"
  type        = string
  default     = null
}

variable "user_group_precedence" {
  description = "The precedence of the user group"
  type        = number
  default     = null
}

variable "user_group_role_arn" {
  description = "The ARN of the IAM role to be associated with the user group"
  type        = string
  default     = null
}

variable "user_groups" {
  description = "A container with the user_groups definitions"
  type        = list(any)
  default     = []
}

################################################
## Create USer
################################################


variable "users" {
  description = "Dynamic list of Cognito Users to create (email)"
  type = map(
    object({
      email = string
    })
  )
}


#########################################################################################################################################
### Deletion Protection
#########################################################################################################################################

variable "deletion_protection" {
  description = "When active, DeletionProtection prevents accidental deletion of your user pool. Before you can delete a user pool that you have protected against deletion, you must deactivate this feature. Valid values are `ACTIVE` and `INACTIVE`."
  type        = string
  default     = "INACTIVE"
}
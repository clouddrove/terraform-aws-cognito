# Managed By : CloudDrove
# Description : This Script is used to create AWS Cognito.
# Copyright @ CloudDrove. All Right Reserved.

#Module      : labels
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  enabled     = var.enabled
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

module "auth-role" {
  source      = "clouddrove/iam-role/aws"
  version     = "1.3.1"
  name        = format("%s-auth-role", module.labels.id)
  environment = var.environment
  label_order = ["name"]
  enabled     = var.enabled

  assume_role_policy = data.aws_iam_policy_document.authenticated_assume.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.authenticated.json

  managedby  = var.managedby
  repository = var.repository
}

data "aws_iam_policy_document" "authenticated_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"

      values = [
        aws_cognito_identity_pool.identity_pool[0].id,
      ]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"

      values = [
        "authenticated",
      ]
    }
  }
}

data "aws_iam_policy_document" "authenticated" {
  statement {
    effect    = "Allow"
    actions   = ["mobileanalytics:PutEvents", "cognito-sync:*", "es:*"]
    resources = ["*"]
  }
}

module "unauth-role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.1"

  name               = format("%s-unauth-role", module.labels.id)
  environment        = var.environment
  label_order        = ["name"]
  enabled            = var.enabled
  assume_role_policy = data.aws_iam_policy_document.unauthenticated_assume.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.unauthenticated.json

  managedby  = var.managedby
  repository = var.repository
}

data "aws_iam_policy_document" "unauthenticated_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"

      values = [
        aws_cognito_identity_pool.identity_pool[0].id,
      ]
    }
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"

      values = [
        "unauthenticated",
      ]
    }
  }
}

data "aws_iam_policy_document" "unauthenticated" {
  statement {
    effect    = "Allow"
    actions   = ["mobileanalytics:PutEvents", "cognito-sync:*", "es:*"]
    resources = ["*"]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool" {
  count            = var.enabled ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.identity_pool[0].id
  roles = {
    "authenticated"   = module.auth-role.arn
    "unauthenticated" = module.unauth-role.arn
  }
}

# --------------------------------------------------------------------------
# Cognito - User Pool
# --------------------------------------------------------------------------

locals {
  alias_attributes = var.alias_attributes == null && var.username_attributes == null ? [
    "email",
    "preferred_username",
  ] : null
}

resource "aws_cognito_user_pool" "user_pool" {
  count            = var.enabled ? 1 : 0
  name             = module.labels.id
  alias_attributes = var.alias_attributes != null ? var.alias_attributes : local.alias_attributes

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = var.admin_create_user_config.allow_admin_create_user_only
    invite_message_template {
      email_message = var.admin_create_user_config.email_message
      email_subject = var.admin_create_user_config.email_subject
      sms_message   = var.admin_create_user_config.sms_message
    }
  }

  dynamic "schema" {
    for_each = var.schema_attributes
    iterator = attribute

    content {
      name                     = attribute.value.name
      required                 = try(attribute.value.required, false)
      attribute_data_type      = attribute.value.type
      developer_only_attribute = try(attribute.value.developer_only_attribute, false)
      mutable                  = try(attribute.value.mutable, true)

      dynamic "number_attribute_constraints" {
        for_each = attribute.value.type == "Number" ? [true] : []

        content {
          min_value = lookup(attribute.value, "min_value", null)
          max_value = lookup(attribute.value, "max_value", null)
        }
      }

      dynamic "string_attribute_constraints" {
        for_each = attribute.value.type == "String" ? [true] : []

        content {
          min_length = lookup(attribute.value, "min_length", 0)
          max_length = lookup(attribute.value, "max_length", 2048)
        }
      }

    }
  }

  dynamic "lambda_config" {
    for_each = try(coalesce(
      var.lambda_create_auth_challenge,
      var.lambda_custom_message,
      var.lambda_define_auth_challenge,
      var.lambda_post_authentication,
      var.lambda_post_confirmation,
      var.lambda_pre_authentication,
      var.lambda_pre_sign_up,
      var.lambda_pre_token_generation,
      var.lambda_user_migration,
      var.lambda_verify_auth_challenge_response
    ), null) == null ? [] : [true]

    content {
      create_auth_challenge          = var.lambda_create_auth_challenge
      custom_message                 = var.lambda_custom_message
      define_auth_challenge          = var.lambda_define_auth_challenge
      post_authentication            = var.lambda_post_authentication
      post_confirmation              = var.lambda_post_confirmation
      pre_authentication             = var.lambda_pre_authentication
      pre_sign_up                    = var.lambda_pre_sign_up
      pre_token_generation           = var.lambda_pre_token_generation
      user_migration                 = var.lambda_user_migration
      verify_auth_challenge_response = var.lambda_verify_auth_challenge_response
    }
  }

  auto_verified_attributes = var.auto_verified_attributes
  mfa_configuration        = var.mfa_configuration
  #   username_attributes = var.username_attributes

  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # software_token_mfa_configuration
  dynamic "software_token_mfa_configuration" {
    for_each = var.allow_software_mfa_token ? [true] : []

    content {
      enabled = true
    }
  }

  username_configuration {
    case_sensitive = var.case_sensitive
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  sms_authentication_message = var.sms_authentication_message

  password_policy {
    minimum_length                   = var.minimum_length
    require_lowercase                = var.require_lowercase
    require_numbers                  = var.require_numbers
    require_symbols                  = var.require_symbols
    require_uppercase                = var.require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }
  tags       = merge(module.labels.tags)
  depends_on = [var.module_depends_on]
}

# --------------------------------------------------------------------------
# Cognito - Client
# --------------------------------------------------------------------------

resource "aws_cognito_user_pool_client" "client" {
  count                                = var.enabled ? length(local.clients) : 0
  allowed_oauth_flows                  = lookup(element(local.clients, count.index), "allowed_oauth_flows", null)
  allowed_oauth_flows_user_pool_client = lookup(element(local.clients, count.index), "allowed_oauth_flows_user_pool_client", null)
  allowed_oauth_scopes                 = lookup(element(local.clients, count.index), "allowed_oauth_scopes", null)
  callback_urls                        = lookup(element(local.clients, count.index), "callback_urls", null)
  default_redirect_uri                 = lookup(element(local.clients, count.index), "default_redirect_uri", null)
  explicit_auth_flows                  = lookup(element(local.clients, count.index), "explicit_auth_flows", null)
  generate_secret                      = lookup(element(local.clients, count.index), "generate_secret", null)
  logout_urls                          = lookup(element(local.clients, count.index), "logout_urls", null)
  name                                 = lookup(element(local.clients, count.index), "name", null)
  read_attributes                      = lookup(element(local.clients, count.index), "read_attributes", null)
  access_token_validity                = lookup(element(local.clients, count.index), "access_token_validity", null)
  id_token_validity                    = lookup(element(local.clients, count.index), "id_token_validity", null)
  refresh_token_validity               = lookup(element(local.clients, count.index), "refresh_token_validity", null)
  supported_identity_providers         = lookup(element(local.clients, count.index), "supported_identity_providers", null)
  prevent_user_existence_errors        = lookup(element(local.clients, count.index), "prevent_user_existence_errors", null)
  write_attributes                     = lookup(element(local.clients, count.index), "write_attributes", null)
  enable_token_revocation              = lookup(element(local.clients, count.index), "enable_token_revocation", null)
  user_pool_id                         = aws_cognito_user_pool.user_pool[0].id

  # token_validity_units
  dynamic "token_validity_units" {
    for_each = length(lookup(element(local.clients, count.index), "token_validity_units", {})) == 0 ? [] : [lookup(element(local.clients, count.index), "token_validity_units")]
    content {
      access_token  = lookup(token_validity_units.value, "access_token", null)
      id_token      = lookup(token_validity_units.value, "id_token", null)
      refresh_token = lookup(token_validity_units.value, "refresh_token", null)
    }
  }
}

locals {
  clients_default = [
    {
      allowed_oauth_flows                  = var.client_allowed_oauth_flows
      allowed_oauth_flows_user_pool_client = var.client_allowed_oauth_flows_user_pool_client
      allowed_oauth_scopes                 = var.client_allowed_oauth_scopes
      callback_urls                        = var.client_callback_urls
      default_redirect_uri                 = var.client_default_redirect_uri
      explicit_auth_flows                  = var.client_explicit_auth_flows
      generate_secret                      = var.client_generate_secret
      logout_urls                          = var.client_logout_urls
      name                                 = var.client_name
      read_attributes                      = var.client_read_attributes
      access_token_validity                = var.client_access_token_validity
      id_token_validity                    = var.client_id_token_validity
      token_validity_units                 = var.client_token_validity_units
      refresh_token_validity               = var.client_refresh_token_validity
      supported_identity_providers         = var.client_supported_identity_providers
      prevent_user_existence_errors        = var.client_prevent_user_existence_errors
      write_attributes                     = var.client_write_attributes
      enable_token_revocation              = var.client_enable_token_revocation
    }
  ]

  # This parses vars.clients which is a list of objects (map), and transforms it to a tuple of elements to avoid conflict with  the ternary and local.clients_default
  clients_parsed = [for e in var.clients : {
    allowed_oauth_flows                  = lookup(e, "allowed_oauth_flows", null)
    allowed_oauth_flows_user_pool_client = lookup(e, "allowed_oauth_flows_user_pool_client", null)
    allowed_oauth_scopes                 = lookup(e, "allowed_oauth_scopes", null)
    callback_urls                        = lookup(e, "callback_urls", null)
    default_redirect_uri                 = lookup(e, "default_redirect_uri", null)
    explicit_auth_flows                  = lookup(e, "explicit_auth_flows", null)
    generate_secret                      = lookup(e, "generate_secret", null)
    logout_urls                          = lookup(e, "logout_urls", null)
    name                                 = lookup(e, "name", null)
    read_attributes                      = lookup(e, "read_attributes", null)
    access_token_validity                = lookup(e, "access_token_validity", null)
    id_token_validity                    = lookup(e, "id_token_validity", null)
    refresh_token_validity               = lookup(e, "refresh_token_validity", null)
    token_validity_units                 = lookup(e, "token_validity_units", {})
    supported_identity_providers         = lookup(e, "supported_identity_providers", null)
    prevent_user_existence_errors        = lookup(e, "prevent_user_existence_errors", null)
    write_attributes                     = lookup(e, "write_attributes", null)
    enable_token_revocation              = lookup(e, "enable_token_revocation", null)
    }
  ]

  clients = length(var.clients) == 0 && (var.client_name == null || var.client_name == "") ? [] : (length(var.clients) > 0 ? local.clients_parsed : local.clients_default)
}

# --------------------------------------------------------------------------
# Cognito - Domain
# --------------------------------------------------------------------------
resource "aws_cognito_user_pool_domain" "domain" {
  count           = !var.enabled || var.domain == null || var.domain == "" ? 0 : 1
  domain          = var.domain
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.user_pool[0].id
}

resource "aws_cognito_identity_pool" "identity_pool" {
  count                            = var.enabled ? 1 : 0
  identity_pool_name               = format("%s_identity_pool", module.labels.id)
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  lifecycle { ignore_changes = [cognito_identity_providers] }
}

# --------------------------------------------------------------------------
# Cognito - User Group
# --------------------------------------------------------------------------
resource "aws_cognito_user_group" "main" {
  count        = var.enabled ? length(local.groups) : 0
  name         = lookup(element(local.groups, count.index), "name")
  description  = lookup(element(local.groups, count.index), "description")
  precedence   = lookup(element(local.groups, count.index), "precedence")
  role_arn     = lookup(element(local.groups, count.index), "role_arn")
  user_pool_id = aws_cognito_user_pool.user_pool[0].id
}

locals {
  groups_default = [
    {
      name        = var.user_group_name
      description = var.user_group_description
      precedence  = var.user_group_precedence
      role_arn    = var.user_group_role_arn

    }
  ]

  # This parses var.user_groups which is a list of objects (map), and transforms it to a tuple of elements to avoid conflict with  the ternary and local.groups_default
  groups_parsed = [for e in var.user_groups : {
    name        = lookup(e, "name", null)
    description = lookup(e, "description", null)
    precedence  = lookup(e, "precedence", null)
    role_arn    = lookup(e, "role_arn", null)
    }
  ]

  groups = length(var.user_groups) == 0 && (var.user_group_name == null || var.user_group_name == "") ? [] : (length(var.user_groups) > 0 ? local.groups_parsed : local.groups_default)
}

# --------------------------------------------------------------------------
# Cognito - Users
# --------------------------------------------------------------------------
resource "aws_cognito_user" "users" {
  for_each = var.users

  user_pool_id             = aws_cognito_user_pool.user_pool[0].id
  username                 = each.value.email
  desired_delivery_mediums = var.desired_delivery_mediums

  attributes = {
    email          = each.value.email
    email_verified = true
  }

  validation_data = {
    email = each.value.email
  }
}

# --------------------------------------------------------------------------
# Cognito - Resource Servers
# --------------------------------------------------------------------------
locals {
  resource_servers = var.resource_servers == null ? [] : var.resource_servers
}

resource "aws_cognito_resource_server" "resource_servers" {
  count      = var.enabled ? length(local.resource_servers) : 0
  name       = lookup(element(local.resource_servers, count.index), "name")
  identifier = lookup(element(local.resource_servers, count.index), "identifier")

  #scope
  dynamic "scope" {
    for_each = lookup(element(local.resource_servers, count.index), "scope")
    content {
      scope_name        = lookup(scope.value, "scope_name")
      scope_description = lookup(scope.value, "scope_description")
    }
  }

  user_pool_id = aws_cognito_user_pool.user_pool[0].id
}
module "labels" {
  source = "git::https://github.com/clouddrove/terraform-labels.git?ref=tags/0.14.0"

  name        = var.name
  environment = var.environment
  attributes  = var.attributes
  repository  = var.repository
  label_order = var.label_order
  managedby   = var.managedby
  enabled     = var.enabled
}

module "auth-role" {
  source = "git::https://github.com/clouddrove/terraform-aws-iam-role.git?ref=tags/0.14.0"

  name        = format("%s-auth-role", module.labels.id)
  environment = var.environment
  label_order = ["name"]
  enabled     = var.enabled

  assume_role_policy = data.aws_iam_policy_document.authenticated_assume.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.authenticated.json
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
        aws_cognito_identity_pool.identity_pool.*.id[0],
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
  source = "git::https://github.com/clouddrove/terraform-aws-iam-role.git?ref=tags/0.14.0"

  name               = format("%s-unauth-role", module.labels.id)
  environment        = var.environment
  label_order        = ["name"]
  enabled            = var.enabled
  assume_role_policy = data.aws_iam_policy_document.unauthenticated_assume.json

  policy_enabled = true
  policy         = data.aws_iam_policy_document.unauthenticated.json
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
        aws_cognito_identity_pool.identity_pool.*.id[0],
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
  identity_pool_id = aws_cognito_identity_pool.identity_pool.*.id[0]
  roles = {
    "authenticated"   = module.auth-role.arn
    "unauthenticated" = module.unauth-role.arn
  }
}

locals {
  alias_attributes = var.alias_attributes == null && var.username_attributes == null ? [
    "email",
    "preferred_username",
  ] : null
}

resource "aws_cognito_user_pool" "user_pool" {
  count = var.module_enabled ? 1 : 0

  name             = module.labels.id
  alias_attributes = var.alias_attributes != null ? var.alias_attributes : local.alias_attributes
  # username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes

  sms_authentication_message = var.sms_authentication_message

  mfa_configuration = var.mfa_configuration

  deletion_protection        = var.deletion_protection

  password_policy {
    minimum_length                   = var.password_minimum_length
    require_lowercase                = var.password_require_lowercase
    require_numbers                  = var.password_require_numbers
    require_symbols                  = var.password_require_symbols
    require_uppercase                = var.password_require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  dynamic "account_recovery_setting" {
    for_each = length(var.account_recovery_mechanisms) > 0 ? [true] : []

    content {
      dynamic "recovery_mechanism" {
        for_each = var.account_recovery_mechanisms
        iterator = recovery

        content {
          name     = recovery.value.name
          priority = recovery.value.priority
        }
      }
    }
  }

  dynamic "device_configuration" {
    for_each = contains(["ALWAYS", "USER_OPT_IN"], upper(var.user_device_tracking)) ? [true] : []

    content {
      device_only_remembered_on_user_prompt = var.user_device_tracking == "USER_OPT_IN"
      challenge_required_on_new_device      = var.challenge_required_on_new_device
    }
  }

  dynamic "software_token_mfa_configuration" {
    for_each = var.allow_software_mfa_token ? [true] : []

    content {
      enabled = false
    }
  }

  username_configuration {
    case_sensitive = var.enable_username_case_sensitivity
  }

  email_configuration {
    email_sending_account  = var.email_sending_account
    reply_to_email_address = var.email_reply_to_address
    source_arn             = var.email_source_arn
    from_email_address     = var.email_from_address
  }

  # The configuration for AdminCreateUser
  # https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_AdminCreateUser.html.
  admin_create_user_config {
    allow_admin_create_user_only = var.allow_admin_create_user_only

    invite_message_template {
      email_subject = var.invite_email_subject
      email_message = var.invite_email_message
      sms_message   = var.invite_sms_message
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

  dynamic "sms_configuration" {
    for_each = var.sms_configuration != null ? [var.sms_configuration] : []

    content {
      external_id    = lookup(var.sms_configuration, "external_id", null)
      sns_caller_arn = lookup(var.sms_configuration, "sns_caller_arn", null)
    }
  }

  # Advanced Security Features
  # Note: Additional pricing applies for Amazon Cognito advanced security features. For details please see:
  # https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pool-settings-advanced-security.html
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  verification_message_template {
    default_email_option  = var.default_email_option
    email_subject         = var.email_subject
    email_message         = var.email_message
    email_subject_by_link = var.email_subject_by_link
    email_message_by_link = var.email_message_by_link
    sms_message           = var.sms_message
  }

  tags       = merge(module.labels.tags)
  depends_on = [var.module_depends_on]
}

##############################################################################################################
# client
##############################################################################################################

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
  user_pool_id                         = aws_cognito_user_pool.user_pool.*.id[0]

  # token_validity_units
  dynamic "token_validity_units" {
    for_each = length(lookup(element(local.clients, count.index), "token_validity_units", {})) == 0 ? [] : [lookup(element(local.clients, count.index), "token_validity_units")]
    content {
      access_token  = lookup(token_validity_units.value, "access_token", null)
      id_token      = lookup(token_validity_units.value, "id_token", null)
      refresh_token = lookup(token_validity_units.value, "refresh_token", null)
    }
  }

  # depends_on = [
  #   aws_cognito_resource_server.resource,
  #   aws_cognito_identity_provider.identity_provider
  # ]
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



##############################################################################################################
##############################################################################################################

resource "aws_cognito_user_pool_domain" "domain" {
  count           = !var.enabled || var.domain == null || var.domain == "" ? 0 : 1
  domain          = var.domain
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.user_pool.*.id[0]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  count                            = var.enabled ? 1 : 0
  identity_pool_name               = format("%s_identity_pool", module.labels.id)
  allow_unauthenticated_identities = false

  # cognito_identity_providers {
  #   client_id     = aws_cognito_user_pool_client.client.*.id[0]
  #   provider_name = aws_cognito_user_pool.user_pool.*.endpoint[0]
  # }

  lifecycle { ignore_changes = [cognito_identity_providers] }
}


##################################################################################################################


resource "aws_cognito_user_group" "main" {
  count        = var.enabled ? length(local.groups) : 0
  name         = lookup(element(local.groups, count.index), "name")
  description  = lookup(element(local.groups, count.index), "description")
  precedence   = lookup(element(local.groups, count.index), "precedence")
  role_arn     = lookup(element(local.groups, count.index), "role_arn")
  user_pool_id        = aws_cognito_user_pool.user_pool.*.id[0]
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


####################################################################################

resource "aws_cognito_user" "users" {
  for_each = var.users

  user_pool_id             = aws_cognito_user_pool.user_pool.*.id[0]
  username                 = each.value.email
  desired_delivery_mediums = ["EMAIL"]

  attributes = {
    email          = each.value.email
    email_verified = true
  }

  validation_data = {
    email = each.value.email
  }

  # depends_on = [aws_lambda_function.pre_sign_up, aws_lambda_permission.pre_sign_up]
}

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

  name        = format("%s-auth-role",module.labels.id)
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
    effect  = "Allow"
    actions = ["mobileanalytics:PutEvents","cognito-sync:*","es:*"]
    resources = ["*"]
  }
}

module "unauth-role" {
  source = "git::https://github.com/clouddrove/terraform-aws-iam-role.git?ref=tags/0.14.0"

  name        = format("%s-unauth-role",module.labels.id)
  environment = var.environment
  label_order = ["name"]
  enabled     = var.enabled
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
    effect  = "Allow"
    actions = ["mobileanalytics:PutEvents","cognito-sync:*","es:*"]
    resources = ["*"]
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool" {
  count = var.enabled ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.identity_pool.*.id[0]
  roles = {
    "authenticated" = module.auth-role.arn
    "unauthenticated" = module.unauth-role.arn
  }
}

resource "aws_cognito_user_pool" "user_pool" {
  count                 = var.enabled ? 1 : 0
  name = module.labels.id

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
    allow_admin_create_user_only = true
  }

  auto_verified_attributes = var.auto_verified_attributes
  mfa_configuration = var.mfa_configuration
  username_attributes = var.username_attributes

  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }
  username_configuration {
    case_sensitive = var.case_sensitive
  }
  sms_authentication_message = var.sms_authentication_message

  tags = module.labels.tags

  password_policy {
    minimum_length = var.minimum_length
    require_lowercase = var.require_lowercase
    require_numbers = var.require_numbers
    require_symbols = var.require_symbols
    require_uppercase = var.require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }
}

resource "aws_cognito_user_pool_client" "client" {
  count                 = var.enabled ? 1 : 0
  name = format("%s_user_client", module.labels.id)

  user_pool_id = aws_cognito_user_pool.user_pool.*.id[0]
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  count                 = var.enabled ? 1 : 0
  domain       = var.cognito_domain
  user_pool_id = aws_cognito_user_pool.user_pool.*.id[0]
  certificate_arn = var.certificate_arn
}

resource "aws_cognito_identity_pool" "identity_pool" {
  count                 = var.enabled ? 1 : 0
  identity_pool_name               = format("%s_identity_pool", module.labels.id)
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id       = aws_cognito_user_pool_client.client.*.id[0]
    provider_name   = aws_cognito_user_pool.user_pool.*.endpoint[0]
  }

  lifecycle {ignore_changes = [cognito_identity_providers]}
}
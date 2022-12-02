output "cognito_map" {
  description = "cognito info"
  value = { "user_pool" = aws_cognito_user_pool.user_pool.*.id[0]
    "identity_pool" = aws_cognito_identity_pool.identity_pool.*.id[0]
    "auth_arn"      = module.auth-role.arn
    "domain"        = format("%s.auth.%s.amazoncognito.com", aws_cognito_user_pool_domain.user_pool_domain.*.domain[0], var.region)
  }
}

output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.*.id[0]
}

output "identity_pool_id" {
  value = aws_cognito_identity_pool.identity_pool.*.id[0]
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.client.*.id[0]
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
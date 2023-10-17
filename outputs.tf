output "user_pool_id" {
  value       = aws_cognito_user_pool.user_pool.*.id[0]
  description = "(Required) User pool the client belongs to."
}

output "name" {
  value       = aws_cognito_user_pool.user_pool.*.name[0]
  description = "(Required) Name of the application client."
}

output "app_client_id" {
  value       = aws_cognito_user_pool_client.client.*.id[0]
  description = "ID of the user pool client."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
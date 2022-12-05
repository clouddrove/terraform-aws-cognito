output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.*.id[0]
}

output "name" {
  value = aws_cognito_user_pool.user_pool.*.name[0]
}

output "app_client_id" {
  value = aws_cognito_user_pool_client.client.*.id[0]
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
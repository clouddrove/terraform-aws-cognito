output "user_pool_id" {
  value       = module.cognito-ex.user_pool_id
  description = "ARN of the Elasticsearch domain."
}

output "identity_pool_id" {
  value       = module.cognito-ex.identity_pool_id
  description = "ARN of the Elasticsearch domain."
}

output "tags" {
  value       = module.cognito-ex.tags
  description = "A mapping of tags to assign to the resource."
}
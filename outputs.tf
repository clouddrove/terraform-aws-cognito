output "user_pool_id" {
  value       = try(aws_cognito_user_pool.user_pool[0].id, null)
  description = "(Required) User pool the client belongs to."
}

output "name" {
  value       = try(aws_cognito_user_pool.user_pool[0].name, null)
  description = "(Required) Name of the application client."
}

output "app_client_id" {
  value       = try(aws_cognito_user_pool_client.client[0].id, null)
  description = "ID of the user pool client."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}
output "identity_provider_names" {
  description = "Names of federated identity providers configured for the Cognito User Pool."

  value = [
    for provider in aws_cognito_identity_provider.identity_provider :
    provider.provider_name
  ]
}
output "identity_providers" {
  description = "Federated identity providers configured for the Cognito User Pool."

  value = {
    for name, provider in aws_cognito_identity_provider.identity_provider :
    name => {
      provider_name = provider.provider_name
      provider_type = provider.provider_type
    }
  }
}
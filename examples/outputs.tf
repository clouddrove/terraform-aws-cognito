output "user_pool" {
  description = "All outputs exposed by the module."
  value       = merge(module.cognito, { client_secrets = null })
}

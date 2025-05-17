output "token_ids" {
  description = "Map of provision token IDs keyed by name"
  value       = teleport_provision_token.aws.*.id
}

output "role_names" {
  description = "Set of role names managed by this module"
  value       = keys(teleport_role.this)
}

output "github_connector_id" {
  value       = var.tp_github_connector.enabled ? teleport_github_connector.this[0].id : null
  description = "ID of the GitHub connector"
}

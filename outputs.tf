output "role_names" {
  description = "Set of role names managed by this module"
  value       = keys(teleport_role.this)
}

output "github_connector_id" {
  value       = var.tp_github_connector.enabled ? teleport_github_connector.this[0].id : null
  description = "ID of the GitHub connector"
}

output "workspace_id" {
  description = "The id of the newly created log analytics workspace"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "workspace_name" {
  description = "The name of the newly created log analytics workspace"
  value       = azurerm_log_analytics_workspace.workspace.name
}



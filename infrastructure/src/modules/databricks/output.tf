output "workspace_id" {
  description = "The id of the newly created Databricks workspace"
  value       = azurerm_databricks_workspace.databricks_workspace.id
}

output "workspace_url" {
  description = "The name of the newly created Databricks workspace"
  value       = azurerm_databricks_workspace.databricks_workspace.workspace_url
}

output "workspace_name" {
  description = "The name of the newly created Databricks workspace"
  value       = azurerm_databricks_workspace.databricks_workspace.name
}



output "id" {
  description = "The id of the newly created synapse workspace"
  value       = azurerm_synapse_workspace.synapse_workspace.id
}

output "name" {
  description = "The name of the newly created synapse workspace"
  value       = azurerm_synapse_workspace.synapse_workspace.name
}



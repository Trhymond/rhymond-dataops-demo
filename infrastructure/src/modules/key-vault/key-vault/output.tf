output "id" {
  description = "The id of the newly created KeyVault"
  value       = azurerm_key_vault.kv.id
}

output "name" {
  description = "The name of the newly created KeyVault"
  value       = azurerm_key_vault.kv.name
}



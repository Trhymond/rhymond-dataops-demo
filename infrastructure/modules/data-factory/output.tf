output "id" {
  description = "The id of the newly created Azure Data Factory "
  value       = azurerm_data_factory.data_factory.id
}

output "name" {
  description = "The name of the newly created Azure Data Factory "
  value       = azurerm_data_factory.data_factory.name
}

output "identity" {
  description = "The Managed Service Identity of the newly created Azure Data Factory "
  value       = azurerm_data_factory.data_factory.identity[0].principal_id
}



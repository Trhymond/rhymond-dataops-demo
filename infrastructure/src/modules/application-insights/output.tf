output "id" {
  description = "The id of the newly created appinsights"
  value       = azurerm_application_insights.appinisghts.id
}

output "name" {
  description = "The name of the newly created appinsights"
  value       = azurerm_application_insights.appinisghts.name
}

output "instrumentation_key" {
  description = "The instrumentation key of the newly created appinsights"
  value       = azurerm_application_insights.appinisghts.instrumentation_key
}



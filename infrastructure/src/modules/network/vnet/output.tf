output "id" {
  description = "The id of the newly created VNet"
  value       = azurerm_virtual_network.vnet.id
}

output "name" {
  description = "The name of the newly created VNet"
  value       = azurerm_virtual_network.vnet.name
}

output "subnets" {
  description = "The ids of the newly created subnets"
  # value       = toset([for v in azurerm_subnet.subnets : v.id])
  value = azurerm_subnet.subnets
}



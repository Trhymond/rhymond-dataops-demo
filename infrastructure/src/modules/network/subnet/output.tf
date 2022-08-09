
output "subnets" {
  description = "The ids of the newly created subnets"
  # value       = toset([for v in azurerm_subnet.subnets : v.id])
  value = azurerm_subnet.subnets
}


output "nsg_association" {
  description = "The ids of the newly created subnets"
  # value       = toset([for v in azurerm_subnet_network_security_group_association.subnet_nsg : v.id])
  value = azurerm_subnet_network_security_group_association.subnet_nsg
}



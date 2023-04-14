output "id" {
  description = "the deployment id "
  value       = azurerm_resource_group_template_deployment.arm_deploy.id
}

output "name" {
  description = "The deployment name "
  value       = azurerm_resource_group_template_deployment.arm_deploy.name
}

output "outputs" {
  description = "The list of all the output varaibles "
  value       = azurerm_resource_group_template_deployment.arm_deploy.outputs
}



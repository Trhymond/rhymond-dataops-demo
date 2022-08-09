data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  data_factory_name = lower("${var.project_name}-${var.domain}-${var.environment_name}-${var.location_short_name}-df")
}

resource "azurerm_data_factory" "data_factory" {
  name                = local.data_factory_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "app_name" = var.project_name,
  })

  identity {
    type = "SystemAssigned"
  }
  public_network_enabled = var.public_network_enabled
}




data "azurerm_client_config" "current" {}

locals {
  resource_group_name = lower("${var.project_name}-${var.resource_group_name}-${var.environment_name}-${var.location_short_name}-rg")
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}



data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  loganalytics_workspace_name = lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-oms")
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = local.loganalytics_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "criticality" = "High",
  })
  sku               = var.sku_name
  retention_in_days = var.retention_in_days
}



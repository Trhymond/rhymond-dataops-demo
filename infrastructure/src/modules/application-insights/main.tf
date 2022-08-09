data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# data "azurerm_log_analytics_workspace" "workspace" {
#   name                = var.log_analytics_workspace_name
#   resource_group_name = var.log_analytics_workspace_rg
# }

locals {
  app_insights_name = lower("${var.project_name}-${var.environment_name}-${var.location_short_name}-apm")
}

resource "azurerm_application_insights" "appinisghts" {
  name                = local.app_insights_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "criticality" = "Low",
  })
  application_type = "web"
  workspace_id     = var.log_analytics_workspace_id

  # depends_on = [
  #   data.azurerm_log_analytics_workspace.workspace
  # ]
}



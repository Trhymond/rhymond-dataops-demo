data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

locals {
  databricks_workspace_name = lower("${var.project_name}-${var.domain}-${var.environment_name}-${var.location_short_name}-dbw")
}

resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                = local.databricks_workspace_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags = merge(var.tags, {
    "app_name" = var.project_name,
  })

  managed_resource_group_name           = "${local.databricks_workspace_name}-rg"
  sku                                   = var.sku
  network_security_group_rules_required = "AllRules"
  public_network_access_enabled         = true

  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = var.virtual_network_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = var.public_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_nsg_association_id
  }
}



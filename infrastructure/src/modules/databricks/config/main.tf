terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.0.0"
    }
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_databricks_workspace" "databricks_workspace" {
  name                = var.databricks_workspace_name
  resource_group_name = var.resource_group_name
}

data "databricks_service_principal" "spn" {
  application_id = var.service_principal_application_id
}

data "databricks_group" "admin_group" {
  display_name = "admins"
}

data "databricks_group" "user_group" {
  display_name = "users"
}



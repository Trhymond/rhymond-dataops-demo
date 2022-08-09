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

# resource "databricks_group" "admin_group" {
#   display_name               = "admins"
#   allow_cluster_create       = true
#   allow_instance_pool_create = true
#   databricks_sql_access      = true
#   workspace_access           = true
# }

# resource "databricks_group" "user_group" {
#   display_name               = "users"
#   allow_cluster_create       = false
#   allow_instance_pool_create = false
#   databricks_sql_access      = true
#   workspace_access           = true
# }

data "databricks_group" "admin_group" {
  display_name = "admins"
}

data "databricks_group" "user_group" {
  display_name = "users"
}

# resource "databricks_group_member" "sp" {
#   group_id  = data.databricks_group.admin_group.id
#   member_id = data.databricks_service_principal.spn.id
# }

# resource "databricks_service_principal" "sp" {
#   application_id       = var.service_principal_application_id
#   display_name         = var.service_principal_name
#   allow_cluster_create = true

#   depends_on = [
#     data.azurerm_databricks_workspace.databricks_workspace
#   ]
# }

# data "databricks_node_type" "smallest" {
#   local_disk = true
# }

# resource "databricks_cluster" "shared_autoscaling" {
#   cluster_name            = "Shared Autoscaling"
#   spark_version           = data.databricks_spark_version.latest_lts.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 20
#   autoscale {
#     min_workers = 1
#     max_workers = 50
#   }
# }



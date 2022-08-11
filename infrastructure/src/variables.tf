
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The project name"
  type        = string
}

variable "landing_zone_resource_group_name" {
  description = "The name of the landing zone resource group"
  type        = string
}

variable "data_resource_group_name" {
  description = "The name of the data zone resource group"
  type        = string
}
variable "location_short_name" {
  description = "The short name of the resource location"
  type        = string
}

variable "location" {
  description = "The name of the resource location"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}

# Network
variable "vnet_address_space" {
  description = "The virtual network address spaces"
  type        = list(string)
}

variable "ddos_protection_plan_id" {
  description = "The DDos protextion plan id"
  type        = string
}

variable "nsg_rules" {
  description = "The network security group rules"
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_ranges    = list(string)
  }))
}

variable "subnets" {
  description = "The subnets in the virtual network"
  type = map(object({
    address_prefix                     = list(string)
    attach_nsg                         = bool
    disable_endppoint_network_policies = bool
    disable_service_network_policies   = bool
    service_endpoints                  = list(string)
    service_delegation = list(object({
      name    = string
      actions = list(string)
    }))
  }))
}

# Log Analytics 
variable "log_analytics_sku_name" {
  description = "The log analytics workspace sku"
  type        = string
}
variable "log_analytics_retention_in_days" {
  description = "The log analytics workspace log retention in days"
  type        = number
}

# KeyVault
variable "keyvault_instance_id" {
  description = "The keyvault instance id"
  type        = number
}

variable "secret_expiration_days" {
  description = "The keyvault secret expiration days from the date of add"
  type        = number
}

variable "keyvault_sku_name" {
  description = "The keyvault sku name"
  type        = string
  default     = "standard"
}

variable "keyvault_ip_rules" {
  description = "The keyvault ip restrictions"
  type        = list(string)
}
variable "keyvault_access_policies" {
  description = "The keyvault access policies"
  type = list(object({
    name           = string
    object_id      = string
    application_id = string
  }))
}

#storage account
variable "storage_account_tier" {
  description = "The tier for the storage account"
  type        = string
}

variable "storage_account_replication_type" {
  description = "The tier for the storage account"
  type        = string
}

# Data Factory  
variable "data_factory_public_network_enabled" {
  description = "(Optional) Is the Data Factory visible to the public network? Defaults to true."
  type        = string
}

variable "data_factory_action_group_shortname" {
  description = "The action group short name"
  type        = string
}

variable "data_factory_alert_email_receivers" {
  description = "The action group short name"
  type = list(object({
    name          = string
    email_address = string
  }))
}


# Databricks
variable "databricks_sku" {
  description = " The sku to use for the Databricks Workspace. Possible values are standard, premium, or trial."
  type        = string
}

variable "databricks_no_public_ip" {
  description = "Are public IP Addresses not allowed? Possible values are true or false. Defaults to false."
  type        = bool
}

variable "databricks_public_subnet_name" {
  description = "The name of the Public Subnet within the Virtual Network."
  type        = string
}

variable "databricks_private_subnet_name" {
  description = "The name of the Private Subnet within the Virtual Network. Required if virtual_network_id is set."
  type        = string
}

# Data Lake
variable "datalake_storage_account_tier" {
  description = "The tier for the storage account"
  type        = string
}

variable "datalake_storage_account_replication_type" {
  description = "The replication type for the storage account"
  type        = string
}
variable "datalake_containers" {
  type = map(object({
    scope = string
    type  = string
    id    = string
    perm  = string
  }))
  description = "A list of Data Lake Gen 2 file system container names and ACL permissions."
}

variable "datalake_container_paths" {
  type = list(object({
    container_name = string
    path_name      = string
  }))
  description = "Data Lake filesystem paths."
  default     = []
}

variable "datalake_storage_account_network_acls" {
  type = object({
    bypass                     = list(string)
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })

  description = "Requires a custom object with attributes 'bypass', 'default_action', 'ip_rules', 'virtual_network_subnet_ids'."
  default     = null
}

variable "datalake_storage_account_role_assignments" {
  type = list(
    object({
      principal_id         = string
      role_definition_name = string
    })
  )
  description = "A list of objects that define role assignments for the storage account."
  default     = []
}


# Synapse Analytics

variable "sqlpool_admin_user_name" {
  type        = string
  description = "The sql pool admin user name"
}

variable "sqlpool_sku_name" {
  type        = string
  description = "The sql pool sku name"
}

# variable "synapse_firewall_rules" {
#   type = map(object({
#     name     = string
#     start_ip = string
#     end_ip   = string
#   }))
#   description = "Allows you to manage an Synapse Firewall Rule."
# }


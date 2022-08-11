
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The application name"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location_short_name" {
  description = "The short name of the resource location"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}

variable "storage_account_tier" {
  description = "The tier for the storage account"
  type        = string
}

variable "storage_account_replication_type" {
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

variable "storage_account_network_acls" {
  type = object({
    bypass                     = list(string)
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })

  description = "Requires a custom object with attributes 'bypass', 'default_action', 'ip_rules', 'virtual_network_subnet_ids'."
  default     = null
}

variable "datalake_container_paths" {
  type = list(object({
    container_name = string
    path_name      = string
  }))
  description = "Data Lake filesystem paths."
  default     = []
}

variable "storage_account_role_assignments" {
  type = list(
    object({
      principal_id         = string
      role_definition_name = string
    })
  )
  description = "A list of objects that define role assignments for the storage account."
  default     = []
}

variable "keyvault_id" {
  description = "The KeyVaullt id"
  type        = string
}

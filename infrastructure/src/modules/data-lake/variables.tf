
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
  description = "The tier for the storage account; Must be Standard or Premium"
  type        = string

  validation {
    condition     = var.storage_account_tier == "Standard" || var.storage_account_tier == "Premium"
    error_message = "The storage account tier must be set to Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid Options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  type        = string

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "The storage account tier must be set to Standard or Premium."
  }
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

variable "secret_expiration_days" {
  type        = number
  description = "The keyvault secret expiration days from the date of add"
  default     = 90
}


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

variable "datalake_filesystem_id" {
  description = "The Data lake filesystem id"
  type        = string
}

variable "keyvault_id" {
  description = "The Keyvault id"
  type        = string
}

variable "secret_expiration_days" {
  type        = number
  description = "The keyvault secret expiration days from the date of add"
  default     = 90
}

variable "sqlpool_admin_user_name" {
  type        = string
  description = "The sql pool admin user name"
}

variable "sqlpool_sku_name" {
  type        = string
  description = "The sql pool sku name"
}

variable "firewall_rules" {
  type = map(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  description = "Allows you to manage an Synapse Firewall Rule."
}


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

variable "storage_tier" {
  description = "The tier for the storage account"
  type        = string
}

variable "storage_replication_type" {
  description = "The replication type for the storage account"
  type        = string
}

variable "storage_fileshares" {
  description = "The filesshares to create on the storage account"
  type = list(object({
    name  = string
    quota = number
  }))
  default = []
}


variable "keyvault_id" {
  description = "The  keyvault id"
  type        = string
}


variable "secret_expiration_days" {
  type        = number
  description = "The keyvault secret expiration days from the date of add"
  default     = 90
}


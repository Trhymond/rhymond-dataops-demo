
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

variable "sku_name" {
  description = "The log analytics workspace sku"
  type        = string
}

variable "retention_in_days" {
  description = "The log analytics workspace log retention in days"
  type        = number
}




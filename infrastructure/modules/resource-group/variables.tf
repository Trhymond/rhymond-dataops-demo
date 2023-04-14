
variable "environment_name" {
  description = "The environment name"
  type        = string
}

variable "project_name" {
  description = "The application name"
  type        = string
}

variable "resource_group_name" {
  description = "The Resource Groupname prefix"
  type        = string
}

variable "location_short_name" {
  description = "The short name of the resource location"
  type        = string
}

variable "location" {
  description = "The name of the resource group location"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}



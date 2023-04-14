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

variable "arm_template_json" {
  description = "The ARM Template filename"
  type        = string
}

variable "arm_template_parameters_json" {
  description = "The ARM Template pararameters"
  type        = string
}



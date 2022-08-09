
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "List of resource tags"
  type        = map(any)
}

variable "datafactory_name" {
  description = "The data factory name"
  type        = string
}


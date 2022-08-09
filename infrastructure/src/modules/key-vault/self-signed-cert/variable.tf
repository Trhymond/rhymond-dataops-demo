variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "keyvault_id" {
  description = "The keyvault id"
  type        = string
}

variable "certificate_name" {
  description = "The keyvault certificate name"
  type        = string
}

variable "cert_hostname" {
  description = "The certificate host name"
  type        = string
}

variable "cert_subjet" {
  description = "The certificates subject"
  type        = string
}

variable "validity_months" {
  description = "The certificates validity months"
  type        = number
}



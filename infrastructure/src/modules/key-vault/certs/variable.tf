
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "keyvault_id" {
  description = "The KeyVault id"
  type        = string
}

variable "certificate" {
  description = "The certificate to import"
  type = object({
    name      = string
    cert_file = string
    password  = string
  })
  # sensitive = true
}



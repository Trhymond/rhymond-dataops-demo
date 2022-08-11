terraform {
  required_version = ">= 1.2.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.12.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

provider "azurerm" {
  alias = "auzrerm"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


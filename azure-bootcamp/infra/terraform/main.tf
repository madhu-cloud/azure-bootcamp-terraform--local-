terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features = {}
}

# Root variables
variable "resource_group" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "aks_name" {
  type = string
}

variable "postgres_name" {
  type = string
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

# Module calls (use resource_group everywhere to match module variable names)
module "network" {
  source         = "./modules/network"
  resource_group = var.resource_group
  location       = var.location
  vnet_name      = var.vnet_name
  address_space  = var.vnet_address_space
}

module "aks" {
  source         = "./modules/aks"
  aks_name       = var.aks_name
  resource_group = var.resource_group
  location       = var.location
  vnet_subnet_id = module.network.aks_subnet_id
}

module "postgres" {
  source         = "./modules/postgres"
  name           = var.postgres_name
  resource_group = var.resource_group
  location       = var.location
  admin_password = var.postgres_admin_password
  subnet_id      = module.network.db_subnet_id
}

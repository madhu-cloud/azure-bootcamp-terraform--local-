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
  features {}
}

# Root variables
variable "resource_group" {
  type        = string
  description = "Name of the resource group"
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

# Module calls
# - network expects `resource_group_name`
# - aks expects `resource_group`
# - postgres expects `resource_group`

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group
  location            = var.location
  vnet_name           = var.vnet_name
  address_space       = var.vnet_address_space
}

module "aks" {
  source         = "./modules/aks"
  aks_name       = var.aks_name
  resource_group = var.resource_group      # aks expects `resource_group`
  location       = var.location

  # network module exports subnet_id (single subnet)
  vnet_subnet_id = module.network.subnet_id
}

module "postgres" {
  source         = "./modules/postgres"
  name           = var.postgres_name
  resource_group = var.resource_group      # postgres expects `resource_group`
  location       = var.location
  admin_password = var.postgres_admin_password

  # network module exports subnet_id (single subnet)
  subnet_id = module.network.subnet_id
}

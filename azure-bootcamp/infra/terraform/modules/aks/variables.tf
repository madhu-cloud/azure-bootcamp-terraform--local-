variable "aks_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "resource_group" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "node_count" {
  type        = number
  description = "Number of nodes in the default node pool"
  default     = 1
}

variable "vm_size" {
  type        = string
  description = "VM size for AKS nodes"
  default     = "Standard_DS2_v2"
}

variable "vnet_subnet_id" {
  type        = string
  description = "Subnet ID for AKS nodes"
}

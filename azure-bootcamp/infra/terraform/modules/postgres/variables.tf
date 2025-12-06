variable "name" {
  type        = string
  description = "Name of the PostgreSQL server"
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

variable "admin_user" {
  type        = string
  description = "Administrator username"
  default     = "pgadmin"
}

variable "admin_password" {
  type        = string
  description = "Administrator password"
  sensitive   = true
}

variable "sku_name" {
  type        = string
  description = "SKU name for PostgreSQL server"
  default     = "Standard_B1ms"
}

variable "storage_mb" {
  type        = number
  description = "Storage size in MB"
  default     = 32768
}

variable "postgres_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "14"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for delegated subnet"
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS Zone ID"
  default     = ""
}

variable "database_name" {
  type        = string
  description = "Name of the database"
  default     = "appdb"
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention in days"
  default     = 7
}

variable "geo_redundant_backup" {
  type        = bool
  description = "Enable geo-redundant backup"
  default     = false
}

variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = "1"
}

variable "allow_azure_services" {
  type        = bool
  description = "Allow Azure services to access the server"
  default     = true
}

variable "subnet_dependency" {
  type        = any
  description = "Subnet dependency for ordering"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = var.name
  resource_group_name    = var.resource_group
  location               = var.location
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  
  sku_name            = var.sku_name
  storage_mb          = var.storage_mb
  version             = var.postgres_version
  
  delegated_subnet_id          = var.subnet_id
  private_dns_zone_id          = var.private_dns_zone_id
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup
  
  zone = var.availability_zone

  tags = var.tags

  depends_on = [var.subnet_dependency]
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name            = var.database_name
  server_id       = azurerm_postgresql_flexible_server.pg.id
  charset         = "UTF8"
  collation       = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  count               = var.allow_azure_services ? 1 : 0
  name                = "AllowAzureServices"
  server_id           = azurerm_postgresql_flexible_server.pg.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

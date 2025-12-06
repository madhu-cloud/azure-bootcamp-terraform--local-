output "postgres_id" {
  value       = azurerm_postgresql_flexible_server.pg.id
  description = "PostgreSQL server ID"
}

output "postgres_fqdn" {
  value       = azurerm_postgresql_flexible_server.pg.fqdn
  description = "PostgreSQL server FQDN"
}

output "postgres_name" {
  value       = azurerm_postgresql_flexible_server.pg.name
  description = "PostgreSQL server name"
}

output "database_id" {
  value       = azurerm_postgresql_flexible_server_database.db.id
  description = "Database ID"
}

output "database_name" {
  value       = azurerm_postgresql_flexible_server_database.db.name
  description = "Database name"
}

output "connection_string" {
  value       = "postgresql://${var.admin_user}@${azurerm_postgresql_flexible_server.pg.fqdn}/${var.database_name}"
  description = "PostgreSQL connection string (without password)"
  sensitive   = true
}

output "admin_username" {
  value       = azurerm_postgresql_flexible_server.pg.administrator_login
  description = "Administrator username"
}

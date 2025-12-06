output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "Virtual network ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Virtual network name"
}

output "subnet_id" {
  value       = azurerm_subnet.subnet.id
  description = "Subnet ID"
}

output "subnet_name" {
  value       = azurerm_subnet.subnet.name
  description = "Subnet name"
}

output "nsg_id" {
  value       = azurerm_network_security_group.nsg.id
  description = "Network security group ID"
}

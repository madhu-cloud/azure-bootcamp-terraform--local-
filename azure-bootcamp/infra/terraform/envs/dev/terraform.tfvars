resource_group     = "rg-bootcamp-dev"
location           = "eastus"
vnet_name          = "vnet-bootcamp-dev"
vnet_address_space = ["10.0.0.0/16"]
aks_name           = "aks-bootcamp-dev"
postgres_name      = "pg-bootcamp-dev"

# DO NOT commit sensitive values to git.
# For local tests you can set a dummy value, but for real infra use secrets.
postgres_admin_password = "ChangeMeToAStrongPassw0rd!"

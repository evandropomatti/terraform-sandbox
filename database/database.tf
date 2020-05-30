locals {
  env = merge(
    yamldecode(file("env/${terraform.workspace}.yaml"))
  )
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = env.group
  location = env.location
}

resource "azurerm_postgresql_server" "postgresql" {
  name                = env.name
  location            = env.location
  resource_group_name = env.group

  administrator_login          = env.username
  administrator_login_password = var.password

  sku_name   = env.sku_name
  version    = env.version
  storage_mb = env.storage

  backup_retention_days        = env.backup_retention_days
  geo_redundant_backup_enabled = env.geo_redundant_backup_enabled
  auto_grow_enabled            = env.auto_grow_enabled

  public_network_access_enabled    = env.public_network_access_enabled

}
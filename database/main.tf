provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" {
  name     = var.group
  location = var.location
}

resource "azurerm_postgresql_server" {
  name                = var.name
  location            = var.location
  resource_group_name = var.group

  administrator_login          = var.username
  administrator_login_password = var.password

  sku_name   = var.sku_name
  version    = var.version
  storage_mb = var.storage

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  auto_grow_enabled            = var.auto_grow_enabled

  public_network_access_enabled    = var.public_network_access_enabled

}
variable "TFC_WORKSPACE_NAME" {
  type = string
}

variable "password" {
  type = string
}

locals {
  env = merge(
    yamldecode(file("env/${var.TFC_WORKSPACE_NAME}.yaml"))
  )
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "group" {
  name     = local.env.group
  location = local.env.location
}

resource "azurerm_postgresql_server" "postgresql" {
  name                = local.env.name
  location            = local.env.location
  resource_group_name = local.env.group

  administrator_login          = local.env.username
  administrator_login_password = var.password

  sku_name   = local.env.sku_name
  version    = local.env.version
  storage_mb = local.env.storage

  backup_retention_days        = local.env.backup_retention_days
  geo_redundant_backup_enabled = local.env.geo_redundant_backup_enabled
  auto_grow_enabled            = local.env.auto_grow_enabled

  public_network_access_enabled    = local.env.public_network_access_enabled
  ssl_enforcement_enabled          = true

}
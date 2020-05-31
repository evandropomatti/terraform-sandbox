variable "CONTAINER_REGISTRY_PASSWORD" {
  type = string
}

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
  storage_mb = local.env.storage_mb

  backup_retention_days        = local.env.backup_retention_days
  geo_redundant_backup_enabled = local.env.geo_redundant_backup_enabled
  auto_grow_enabled            = local.env.auto_grow_enabled

  public_network_access_enabled    = local.env.public_network_access_enabled
  ssl_enforcement_enabled          = true

  depends_on = [
    azurerm_resource_group.group,
  ]

}

resource "azurerm_app_service_plan" "default" {
  name                = "plan-myapp-terraform"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "myapp" {
  name                = "app-myapp-terraform"
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  app_service_plan_id = azurerm_app_service_plan.default.id

  site_config {
    app_command_line = "node app.js"
    linux_fx_version  = "DOCKER|pomatti.azurecr.io/my-app:latest"
  }

  # app_settings = {
  #   #"DOCKER_ENABLE_CI" = "true"
  #   #"WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  #   #"DOCKER_REGISTRY_SERVER_PASSWORD"     = var.CONTAINER_REGISTRY_PASSWORD
  #   #"DOCKER_REGISTRY_SERVER_URL"          = "https://pomatti.azurecr.io"
  #   #"DOCKER_REGISTRY_SERVER_USERNAME"     = "pomatti"
  # }  

  lifecycle {
    ignore_changes = [
      site_config.0.linux_fx_version, # deployments are made outside of Terraform
    ]
  }
}
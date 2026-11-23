locals {
  prefix = "${var.project}-${var.environment}"

  tags = merge(
    {
      project     = var.project
      environment = var.environment
      managed_by  = "opentofu"
    },
    var.tags
  )
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.primary_location
  tags     = local.tags
}

module "registry" {
  source = "./modules/registry"

  name                = "acr${replace(local.prefix, "-", "")}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.primary_location
  tags                = local.tags
}

module "postgres" {
  source = "./modules/postgres"

  name                  = "psql-${local.prefix}-${random_string.suffix.result}"
  resource_group_name   = azurerm_resource_group.this.name
  location              = coalesce(var.database.location, var.primary_location)
  sku_name              = var.database.sku_name
  storage_mb            = var.database.storage_mb
  pg_version            = var.database.pg_version
  backup_retention_days = var.database.backup_retention_days
  database_name         = var.database.database_name
  tags                  = local.tags
}

module "gateway" {
  source   = "./modules/web_app"
  for_each = var.gateways

  name                = "app-${local.prefix}-gw-${each.key}-${random_string.suffix.result}"
  plan_name           = "asp-${local.prefix}-gw-${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  location            = coalesce(each.value.location, var.primary_location)
  sku_name            = each.value.sku_name
  worker_count        = each.value.worker_count
  tags                = local.tags

  docker_image      = each.value.image
  container_port    = each.value.port
  health_check_path = each.value.health_check_path
  registry_url      = "https://${module.registry.login_server}"
  registry_username = module.registry.admin_username
  registry_password = module.registry.admin_password

  app_settings = merge(
    each.value.app_settings,
    var.gateway_secrets,
    { DATABASE_URL = module.postgres.connection_string }
  )
}

module "frontend" {
  source = "./modules/web_app"

  name                = "app-${local.prefix}-web-${random_string.suffix.result}"
  plan_name           = "asp-${local.prefix}-web"
  resource_group_name = azurerm_resource_group.this.name
  location            = coalesce(var.frontend.location, var.primary_location)
  sku_name            = var.frontend.sku_name
  worker_count        = var.frontend.worker_count
  tags                = local.tags

  docker_image      = var.frontend.image
  container_port    = var.frontend.port
  health_check_path = var.frontend.health_check_path
  registry_url      = "https://${module.registry.login_server}"
  registry_username = module.registry.admin_username
  registry_password = module.registry.admin_password

  app_settings = merge(
    var.frontend.app_settings,
    var.frontend_secrets,
    { GATEWAY_URLS = join(",", [for g in module.gateway : "https://${g.default_hostname}"]) }
  )
}

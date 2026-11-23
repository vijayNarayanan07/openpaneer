resource "azurerm_service_plan" "this" {
  name                = var.plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  worker_count        = var.worker_count
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    always_on           = !contains(["F1", "D1"], var.sku_name)
    health_check_path   = var.health_check_path

    application_stack {
      docker_image_name        = var.docker_image
      docker_registry_url      = var.registry_url
      docker_registry_username = var.registry_username
      docker_registry_password = var.registry_password
    }
  }

  app_settings = merge(var.app_settings, {
    WEBSITES_PORT                       = tostring(var.container_port)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  })

  # The app pipeline owns the image tag. OpenTofu must not revert it.
  lifecycle {
    ignore_changes = [site_config[0].application_stack[0].docker_image_name]
  }
}

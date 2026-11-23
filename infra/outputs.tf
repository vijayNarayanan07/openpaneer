output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "frontend_url" {
  value = "https://${module.frontend.default_hostname}"
}

output "frontend_app_name" {
  value = module.frontend.name
}

output "gateway_urls" {
  value = { for k, g in module.gateway : k => "https://${g.default_hostname}" }
}

output "gateway_app_names" {
  value = { for k, g in module.gateway : k => g.name }
}

output "acr_login_server" {
  value = module.registry.login_server
}

output "acr_admin_username" {
  value = module.registry.admin_username
}

output "acr_admin_password" {
  value     = module.registry.admin_password
  sensitive = true
}

output "postgres_fqdn" {
  value = module.postgres.fqdn
}

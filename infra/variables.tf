variable "project" {
  description = "Short project name used in resource names (lowercase letters/digits)."
  type        = string
}

variable "environment" {
  description = "Environment name, e.g. dev or test."
  type        = string
}

variable "primary_location" {
  description = "Default Azure region, e.g. centralindia."
  type        = string
  default     = "centralindia"
}

variable "tags" {
  description = "Extra tags merged onto every resource."
  type        = map(string)
  default     = {}
}

variable "database" {
  description = "PostgreSQL Flexible Server settings."
  type = object({
    location              = optional(string) # defaults to primary_location
    sku_name              = optional(string, "B_Standard_B1ms")
    storage_mb            = optional(number, 32768)
    pg_version            = optional(string, "16")
    backup_retention_days = optional(number, 7)
    database_name         = optional(string, "appdb")
  })
  default = {}
}

variable "frontend" {
  description = "Frontend App Service settings."
  type = object({
    location          = optional(string) # defaults to primary_location
    sku_name          = optional(string, "B1")
    worker_count      = optional(number, 1)
    image             = optional(string, "web:latest")
    port              = optional(number, 3000)
    health_check_path = optional(string)
    app_settings      = optional(map(string), {})
  })
  default = {}
}

variable "gateways" {
  description = "Map of gateway key => settings. One plan + web app is created per entry."
  type = map(object({
    location          = optional(string) # defaults to primary_location
    sku_name          = optional(string, "B1")
    worker_count      = optional(number, 1)
    image             = optional(string, "gateway:latest")
    port              = optional(number, 3000)
    health_check_path = optional(string)
    app_settings      = optional(map(string), {})
  }))
}

variable "gateway_secrets" {
  description = "Secret app settings applied to every gateway. Pass via TF_VAR_gateway_secrets (JSON)."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "frontend_secrets" {
  description = "Secret app settings for the frontend. Pass via TF_VAR_frontend_secrets (JSON)."
  type        = map(string)
  default     = {}
  sensitive   = true
}

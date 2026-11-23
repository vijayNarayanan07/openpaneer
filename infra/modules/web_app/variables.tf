variable "name" { type = string }
variable "plan_name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "sku_name" { type = string }
variable "worker_count" { type = number }
variable "tags" { type = map(string) }

variable "docker_image" {
  description = "Image name with tag, e.g. gateway:latest (registry host is added separately)."
  type        = string
}
variable "container_port" {
  type    = number
  default = 3000
}
variable "health_check_path" {
  type    = string
  default = null
}
variable "registry_url" { type = string }
variable "registry_username" { type = string }
variable "registry_password" {
  type      = string
  sensitive = true
}

variable "app_settings" {
  type      = map(string)
  default   = {}
  sensitive = true
}

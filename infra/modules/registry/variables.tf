variable "name" {
  description = "Globally unique, 5-50 alphanumeric characters."
  type        = string
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

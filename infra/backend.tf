# Partial backend config. The state account name and key come from
# envs/<env>.backend.hcl, and the credential comes from ARM_ACCESS_KEY.
#   tofu init -backend-config=envs/dev.backend.hcl
terraform {
  backend "azurerm" {
    resource_group_name = "rg-tfstate"
    container_name      = "tfstate"
  }
}

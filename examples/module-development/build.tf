module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "key_vault_secrets" {
  source       = "../../"
  key_vault_id = data.azurerm_key_vault.mgmt_kv.id

  key_vault_secrets = [
    {
      secret_name  = "static-secret"
      secret_value = "hardcoded-value"
      content_type = "text/plain"
      expiry_days  = 90
      tags = {
        environment = "dev"
        owner       = "team-a"
      }
    },
    {
      secret_name              = "random-password-secret"
      generate_random_password = true
      random_length            = 32
      content_type             = "application/octet-stream"
      expiry_days              = 180
      tags = {
        environment = "prod"
        usage       = "app-auth"
      }
    },
    {
      secret_name     = "api-token-secret"
      secret_value    = "s3cr3t-AP1-T0k3n"
      expiration_date = "2026-01-01T00:00:00Z"
      creation_date   = "2025-03-27T00:00:00Z"
      content_type    = "application/json"
    }
  ]
}

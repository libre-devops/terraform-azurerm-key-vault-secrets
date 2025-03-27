output "created_secrets" {
  description = "A map of the created secrets with their names and metadata"
  sensitive   = true
  value = {
    for k, v in azurerm_key_vault_secret.secrets : k => {
      secret_id       = v.id
      secret_name     = v.name
      content_type    = v.content_type
      expiration_date = v.expiration_date
      creation_date   = v.not_before_date
    }
  }
}

output "random_passwords" {
  description = "Map of generated random passwords for secrets"
  sensitive   = true
  value = {
    for k, v in random_password.rand_password : k => v.result
  }
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to store the secrets"
  type        = string
  nullable    = false
}

variable "key_vault_secrets" {
  description = "List of secrets to be created"
  type = list(object({
    secret_name               = string
    secret_value              = optional(string)
    generate_random_password  = optional(bool, false)
    random_length             = optional(number, 21)
    content_type              = optional(string, "text/plain")
    creation_date             = optional(string, null)
    expiration_date           = optional(string, null)
    expiry_days               = optional(number, 365)
    tags                      = optional(map(string))
  }))
}

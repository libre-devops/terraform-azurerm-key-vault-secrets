```hcl
locals {
  current_time_utc = timestamp()

  calculated_secrets = [
    for s in var.key_vault_secrets : merge(s, {
      creation_date   = coalesce(s.creation_date, local.current_time_utc)
      expiration_date = coalesce(s.expiration_date, timeadd(local.current_time_utc, format("%dh", s.expiry_days * 24)))
    })
  ]

  # Create a map of generated passwords for secrets that request them
  generated_passwords = {
    for k, v in random_password.rand_password : k => v.result
  }
}

resource "random_password" "rand_password" {
  for_each = {
    for s in local.calculated_secrets : s.secret_name => s if s.generate_random_password == true
  }

  length  = lookup(each.value, "random_length", 21)
  special = true
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = {
    for s in local.calculated_secrets : s.secret_name => s
  }

  name = each.value.secret_name
  value = coalesce(each.value.secret_value, lookup(local.generated_passwords, each.key, null)
  )
  key_vault_id    = var.key_vault_id
  content_type    = each.value.content_type
  expiration_date = each.value.expiration_date
  not_before_date = each.value.creation_date
  tags            = each.value.tags

  lifecycle {
    ignore_changes = [
      expiration_date,
      not_before_date
    ]
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_password.rand_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault to store the secrets | `string` | n/a | yes |
| <a name="input_key_vault_secrets"></a> [key\_vault\_secrets](#input\_key\_vault\_secrets) | List of secrets to be created | <pre>list(object({<br/>    secret_name              = string<br/>    secret_value             = optional(string)<br/>    generate_random_password = optional(bool, false)<br/>    random_length            = optional(number, 21)<br/>    content_type             = optional(string, "text/plain")<br/>    creation_date            = optional(string, null)<br/>    expiration_date          = optional(string, null)<br/>    expiry_days              = optional(number, 365)<br/>    tags                     = optional(map(string))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_secrets"></a> [created\_secrets](#output\_created\_secrets) | A map of the created secrets with their names and metadata |
| <a name="output_random_passwords"></a> [random\_passwords](#output\_random\_passwords) | Map of generated random passwords for secrets |

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

  name            = each.value.secret_name
  value           = coalesce(each.value.secret_value, lookup(local.generated_passwords, each.key, null)
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

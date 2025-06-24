module "key-vault" {
  source              = "./modules/key-vault"
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id

  tags = {
    Environment = "dev"
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_access_policy" "hcp" {
  key_vault_id = module.key-vault.keyvault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]

  key_permissions = [
    "Backup",
    "Create",
    "Decrypt",
    "Delete",
    "Encrypt",
    "Get",
    "Import",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Sign",
    "UnwrapKey",
    "Update",
    "Verify",
    "WrapKey",
    "Release",
    "Rotate",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]

  certificate_permissions = [
    "Backup",
    "Create",
    "Delete",
    "DeleteIssuers",
    "Get",
    "GetIssuers",
    "Import",
    "List",
    "ListIssuers",
    "ManageContacts",
    "ManageIssuers",
    "Purge",
    "Recover",
    "Restore",
    "SetIssuers",
    "Update"
  ]
}

resource "random_password" "db-password" {
  length           = 16
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  override_special = "!&#$^<>-"
}

resource "azurerm_key_vault_secret" "db-password" {
  name         = "db-password"
  value        = random_password.db-password.result
  key_vault_id = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }

  depends_on = [azurerm_key_vault_access_policy.hcp]
}

resource "azurerm_key_vault_secret" "email-host-user" {
  name         = "email-host-user"
  value        = var.email_host_user_secret
  key_vault_id = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }

  depends_on = [azurerm_key_vault_access_policy.hcp]
}

resource "azurerm_key_vault_secret" "email-host-password" {
  name         = "email-host-password"
  value        = var.email_host_password_secret
  key_vault_id = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }

  depends_on = [azurerm_key_vault_access_policy.hcp]
}

resource "azurerm_key_vault_secret" "secret-key" {
  name         = "secret-key"
  value        = var.secret_key_secret
  key_vault_id = module.key-vault.keyvault_id

  tags = {
    Environment = "dev"
  }

  depends_on = [azurerm_key_vault_access_policy.hcp]
}

resource "azurerm_key_vault_certificate" "this" {
  name         = "the-plug-application-gateway-tls"
  key_vault_id = module.key-vault.keyvault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      subject            = "CN=theplug.software"
      validity_in_months = 12

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      extended_key_usage = [
        # Server Authentication = 1.3.6.1.5.5.7.3.1
        # Client Authentication = 1.3.6.1.5.5.7.3.2
        "1.3.6.1.5.5.7.3.1"
      ]

      subject_alternative_names {
        dns_names = ["theplug.software"]
      }
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }
      trigger {
        days_before_expiry = 30
      }
    }
  }

  tags = {
    Environment = "dev"
  }

  depends_on = [azurerm_key_vault_access_policy.hcp]
}
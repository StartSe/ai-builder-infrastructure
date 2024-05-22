provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_prod" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = "builderstoragestartse"
  resource_group_name      = azurerm_resource_group.rg_prod.name
  location                 = azurerm_resource_group.rg_prod.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  min_tls_version          = "TLS1_2"
  depends_on               = [azurerm_resource_group.rg_prod]

}
resource "azurerm_storage_share" "share" {
  name                 = "storageshare"
  quota                = "1"
  storage_account_name = azurerm_storage_account.this.name
  depends_on           = [azurerm_storage_account.this]
}

resource "azurerm_container_group" "flowise" {
  name                = var.project_name
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  ip_address_type     = "Public"
  os_type             = "Linux"
  dns_name_label      = var.project_name
  exposed_port = [
    {
      port     = 80
      protocol = "TCP"
    },
    {
      port     = 443
      protocol = "TCP"
    }
  ]

  container {
    name   = var.container_app_name
    image  = var.source_image
    cpu    = "0.5"
    memory = "1.5"

    commands = [
      "/bin/sh",
      "-c",
      "pnpm start"
    ]
    ports {
      port     = 3000
      protocol = "TCP"
    }
    environment_variables = {
      PORT                        = 3000
      PASSPHRASE                  = var.passphrase
      LOG_LEVEL                   = "DEBUG"
      FLOWISE_USERNAME            = var.flowise_username
      FLOWISE_PASSWORD            = var.flowise_password
      OVERRIDE_DATABASE           = false
      DEBUG                       = true
      FLOWISE_SECRETKEY_OVERWRITE = var.flowise_secretkey_overwrite
      DATABASE_PATH               = var.database_path
      APIKEY_PATH                 = var.apikey_path
      SECRETKEY_PATH              = var.secretkey_path
      BLOB_STORAGE_PATH           = var.blob_storage_path
      FLOWISE_USERNAME            = var.flowise_username
      FLOWISE_PASSWORD            = var.flowise_password
      PASSPHRASE                  = var.passphrase
      TESTE                       = "TESTE"
    }

    volume {
      name                 = "flowise"
      mount_path           = "/opt/flowise/.flowise"
      share_name           = azurerm_storage_share.share.name
      storage_account_name = azurerm_storage_account.this.name
      storage_account_key  = azurerm_storage_account.this.primary_access_key
    }
  }

  container {
    name   = "caddy"
    image  = "caddy"
    memory = "0.5"
    cpu    = "0.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    ports {
      port     = 443
      protocol = "TCP"
    }

    commands = ["caddy", "reverse-proxy", "--from", "${var.project_name}.eastus2.azurecontainer.io", "--to", "localhost:3000"]
  }
}

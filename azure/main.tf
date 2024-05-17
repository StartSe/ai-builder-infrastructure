provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_prod" {
  name              = var.resource_group_name
  location          = var.location
}

resource "azurerm_container_app_environment" "cae_ai_builder" {
  depends_on          = [azurerm_resource_group.rg_prod]
  name                = var.container_environment_name
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  tags = {}
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
  quota                = "200"
  storage_account_name = azurerm_storage_account.this.name
  depends_on           = [azurerm_storage_account.this]
}


resource "azurerm_container_app_environment_storage" "this" {
  name                         = "mycontainerappstorage"
  container_app_environment_id = azurerm_container_app_environment.cae_ai_builder.id
  account_name                 = azurerm_storage_account.this.name
  share_name                   = azurerm_storage_share.share.name
  access_key                   = azurerm_storage_account.this.primary_access_key
  access_mode                  = "ReadWrite"
  depends_on                   = [azurerm_storage_account.this, azurerm_container_app_environment.cae_ai_builder, azurerm_storage_share.share]
}




resource "azurerm_container_app" "ca_ai_builder" {
  depends_on                   = [azurerm_resource_group.rg_prod, azurerm_container_app_environment.cae_ai_builder, azurerm_container_app_environment_storage.this, azurerm_storage_share.share]
  name                         = var.project_name
  container_app_environment_id = azurerm_container_app_environment.cae_ai_builder.id
  resource_group_name          = azurerm_resource_group.rg_prod.name
  revision_mode                = "Single"

  tags = {
    Environment = "Prod"
    Tier        = "web"
  }

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name   = var.container_app_name
      image  = var.source_image
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "PASSPHRASE"
        value = var.passphrase
      }
      env {
        name  = "LOG_LEVEL"
        value = "DEBUG"
      }
      env {
        name  = "FLOWISE_USERNAME"
        value = var.flowise_username
      }
      env {
        name  = "FLOWISE_PASSWORD"
        value = var.flowise_password
      }
      env {
        name  = "OVERRIDE_DATABASE"
        value = false
      }
      env {
        name  = "DEBUG"
        value = true
      }
      env {
        name  = "FLOWISE_SECRETKEY_OVERWRITE"
        value = var.flowise_secretkey_overwrite
      }
      env {
        name  = "DATABASE_PATH"
        value = var.database_path
      }
      env {
        name  = "APIKEY_PATH"
        value = var.apikey_path

      }
      env {
        name  = "SECRETKEY_PATH"
        value = var.secretkey_path
      }
      env {

        name  = "LOG_PATH"
        value = var.log_path
      }
      env {
        name  = "BLOB_STORAGE_PATH"
        value = var.blob_storage_path
      }
      volume_mounts {
        name = azurerm_storage_share.share.name

        path = "/${azurerm_storage_share.share.name}"
      }
    }
    volume {
      name         = azurerm_storage_share.share.name
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.this.name
    }
  }
  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 3000
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

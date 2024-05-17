provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_prod" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "pg_ai_builder" {
  depends_on          = [azurerm_resource_group.rg_prod]
  name                = var.database_server_name
  zone                = "1"
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  version                = "12"
  administrator_login    = var.postgres_admin
  administrator_password = var.postgres_password

  sku_name              = "B_Standard_B1ms"
  storage_mb            = "32768"
  backup_retention_days = 7
}

resource "azurerm_postgresql_flexible_server_database" "builder_database" {
  depends_on = [azurerm_resource_group.rg_prod, azurerm_postgresql_flexible_server.pg_ai_builder]
  name       = var.database_name
  charset    = "UTF8"
  collation  = "en_US.utf8"
  server_id  = azurerm_postgresql_flexible_server.pg_ai_builder.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "pg_firewall" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.pg_ai_builder.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_extensions" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = "VECTOR,UUID-OSSP,VECTOR"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_max_connections" {
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = 80
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_max_parallel_maintenance_workers" {
  name      = "max_parallel_maintenance_workers"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = 64
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_pg_qs_query_capture_mode" {
  name      = "pg_qs.query_capture_mode"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = "ALL"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_pgms_wait_sampling_query_capture_mode" {
  name      = "pgms_wait_sampling.query_capture_mode"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = "ALL"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_azure_require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = "OFF"
}

resource "azurerm_postgresql_flexible_server_configuration" "pg_config_track_io_timing" {
  name      = "track_io_timing"
  server_id = azurerm_postgresql_flexible_server.pg_ai_builder.id
  value     = "ON"
}

resource "azurerm_container_app_environment" "cae_ai_builder" {
  depends_on          = [azurerm_resource_group.rg_prod]
  name                = var.container_environment_name
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  tags = {}
}


resource "azurerm_container_app" "ca_ai_builder" {
  depends_on = [azurerm_resource_group.rg_prod, azurerm_postgresql_flexible_server.pg_ai_builder,azurerm_postgresql_flexible_server_database.builder_database,azurerm_container_app_environment.cae_ai_builder,azurerm_postgresql_flexible_server_configuration.pg_config_track_io_timing,azurerm_postgresql_flexible_server_configuration.pg_config_azure_require_secure_transport,azurerm_postgresql_flexible_server_configuration.pg_config_azure_pgms_wait_sampling_query_capture_mode,azurerm_postgresql_flexible_server_configuration.pg_config_azure_pg_qs_query_capture_mode,azurerm_postgresql_flexible_server_configuration.pg_config_azure_max_parallel_maintenance_workers,azurerm_postgresql_flexible_server_configuration.pg_config_azure_max_connections,azurerm_postgresql_flexible_server_configuration.pg_config_azure_extensions,azurerm_postgresql_flexible_server_firewall_rule.pg_firewall]
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
        name  = "DATABASE_TYPE"
        value = "postgres"
      }
      env {
        name  = "DATABASE_HOST"
        value = var.database_container_app_host
      }
      env {
        name  = "DATABASE_NAME"
        value = var.database_name
      }
      env {
        name  = "DATABASE_USER"
        value = var.postgres_admin
      }
      env {
        name  = "DATABASE_PORT"
        value = var.database_port
      }
      env {
        name  = "DATABASE_PASSWORD"
        value = var.postgres_password
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

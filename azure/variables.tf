
variable "resource_group_name" {
  description = "Resource group name"
  default = "rg-ai-exp-prod-eastus2"
}
variable "container_environment_name" {
  description = "Container environment name"
  default = "cae-ai-builder-prod-east2"
}

variable "container_app_name" {
  description = "Container app name"
  default = "ca-ai-builder-prod-east2"
}

variable "location" {
  description = "Service location"
  default = "East US 2"
}

variable "project_name" {
  description = "Project name"
}

variable "webapp_ip_rules" {
  description = "Webapp ip rules"
}

variable "postgres_admin" {
  description = "Postgres server admin user name."
}

variable "postgres_password" {
  description = "Postgres server admin password"
}

variable "subscription_id" {
  description = "Azure subscription id"
}

variable "subscription_name" {
  description = "Azure subscription name"
}

variable "passphrase" {
  description = "value of the passphrase"
}

variable "flowise_username" {
  description = "value of the flowise username. Will be the login of the application"
}

variable "flowise_password" {
  description = "value of the flowise password. Will be the password of the application"
}

variable "source_image" {
  description = "value of the flowise image"
}

variable "database_name" {
  description = "value of the database name"
}

variable "flowise_secretkey_overwrite" {
  description = "value of the flowise secretkey overwrite"
}

variable "database_port" {
  description = "value of the database port"
}

variable "database_container_app_host" {
  description = "value of the database container app host"
}

variable "database_server_name" {
  description = "value of the database server name"
}

variable "database_path" {
  description = "value of the database path"
}

variable "apikey_path" {
  description = "value of the apikey path"
}

variable "secretkey_path" {
  description = "value of the secretkey path"
}

variable "log_path" {
  description = "value of the log path"
}

variable "blob_storage_path" {
  description = "value of the blob storage path"
}


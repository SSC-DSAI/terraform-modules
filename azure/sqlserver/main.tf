# ---------------------------------------------------------------------------------------------------------------------
# Data
# ---------------------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "random_password" "this" {
  length            = 16
  upper             = true
  lower             = true
  special           = true
  number            = true
  override_special  = "@"
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating SQL Server Admin Password and store in Azure Key Vault
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "this" {
  name         = var.administrator_secret_name
  value        = random_password.this.result
  key_vault_id = data.azurerm_key_vault.this.id
  expiration_date = timeadd(timestamp(), "17520h") # expires in 2 years
  content_type = "text/plain"
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure SQL Server
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_sql_server" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.administrator_user_login
  administrator_login_password = random_password.this.result

  extended_auditing_policy {
    storage_endpoint            = data.azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key  = data.azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 90
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure SQL Server Firewall Rules
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_sql_firewall_rule" "adf" {
  name                = "ADF"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.this.name
  start_ip_address    = var.adf_ip_address
  end_ip_address      = var.adf_ip_address
}

resource "azurerm_sql_firewall_rule" "ssc_vpn" {
  name                = "SSC VPN"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.this.name
  start_ip_address    = var.ssc_vpn_ip_address
  end_ip_address      = var.ssc_vpn_ip_address
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating Azure SQL Database
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_sql_database" "this" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.this.name

  extended_auditing_policy {
    storage_endpoint            = data.azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key  = data.azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 90
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating a container in Azure Storage Account for Vulnerability Assessment
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  name                  = "sqlserver-assessment"
  storage_account_name  = data.azurerm_storage_account.this.name
  container_access_type  = "blob"
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating an Azure SQL Server Security Alert Policy
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_mssql_server_security_alert_policy" "this" {
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.this.name
  state               = "Enabled"
  email_account_admins       = true
  email_addresses = ["ssc.dsai-sdia.spc@ssc-spc.gc.ca"]
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating an Azure SQL Server Security Alert Policy
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_mssql_server_vulnerability_assessment" "this" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.this.id
  storage_container_path          = "${data.azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.this.name}/"
  storage_account_access_key      = data.azurerm_storage_account.this.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      "ssc.dsai-sdia.spc@ssc-spc.gc.ca"
    ]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Creating an Azure SQL Server Active Directory Admin
# ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = azurerm_sql_server.this.name
  resource_group_name = var.resource_group_name
  login               = "sqladmin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}
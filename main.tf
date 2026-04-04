terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }
    backend "azurerm" {
        resource_group_name     = "hybrid-identity-lab"
        storage_account_name    = "tfstatei600dlw0"
        container_name          = "tfstate"
        key                     = "terraform.tfstate"
    }
}

provider "azurerm" {
    features {}
    resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "lab" {
    name     = "hybrid-identity-lab"
    location = "East US"
}

resource "random_string" "storage_suffix" {
    length  = 8
    special = false
    upper   = false
}

resource "azurerm_storage_account" "tfstate" {
    name                     = "tfstate${random_string.storage_suffix.result}"
    resource_group_name      = azurerm_resource_group.lab.name
    location                 = azurerm_resource_group.lab.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
    name                = "tfstate"
    storage_account_id  = azurerm_storage_account.tfstate.id
}
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 4.0"
        }
    }
}

provider "azurerm" {
    features {}
    subscription_id                 = "7517fa1a-63f7-456a-a716-8cc1e6e9e015"
    resource_provider_registrations = "none"
}

resource "azurerm_resource_group" "lab" {
    name     = "hybrid-identity-lab"
    location = "East US"
}

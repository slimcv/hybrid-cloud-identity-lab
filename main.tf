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

    depends_on = [
        azurerm_widnows_virtual_machine.management,
        azurerm_subnet,network_security_group_association.management,
        azurerm_network_interface.management,
        azurerm_public_ip.management,
        azurerm_subnet.management,
        azurerm_subnet.identity,
        azurerm_subnet.endpoints,
        azurerm_virutal_network.lab,
        azurerm_network_security_group.management,
    ]
}

resource "azurerm_storage_container" "tfstate" {
    name                = "tfstate"
    storage_account_id  = azurerm_storage_account.tfstate.id
}

resource "azurerm_virtual_network" "lab" {
    name                = "lab-vnet"
    location            = azurerm_resource_group.lab.location
    resource_group_name = azurerm_resource_group.lab.name
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "management" {
    name                 = "management"
    resource_group_name  = azurerm_resource_group.lab.name
    virtual_network_name = azurerm_virtual_network.lab.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "identity" {
    name                 = "identity"
    resource_group_name  = azurerm_resource_group.lab.name
    virtual_network_name = azurerm_virtual_network.lab.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "endpoints" {
    name                   = "endpoints"
    resource_group_name    = azurerm_resource_group.lab.name
    virtual_network_name   = azurerm_virtual_network.lab.name
    address_prefixes       = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "management" {
    name                = "management-nsg"
    location            = azurerm_resource_group.lab.location
    resource_group_name = azurerm_resource_group.lab.name

    security_rule {
        name                        = "Allow-RDP"
        priority                    = 100
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      ="3389"
        source_address_prefix       = "*"
        destination_address_prefix  = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "management" {
    subnet_id                   = azurerm_subnet.management.id
    network_security_group_id   = azurerm_network_security_group.management.id
}

resource "azurerm_public_ip" "management" {
    name                    = "management-pip"
    location                = azurerm_resource_group.lab.location
    resource_group_name     = azurerm_resource_group.lab.name
    allocation_method       = "Static"
}

resource "azurerm_network_interface" "management" {
    name                    = "management-nic"
    location                = azurerm_resource_group.lab.location
    resource_group_name     = azurerm_resource_group.lab.name

    ip_configuration {
        name                            = "internal"
        subnet_id                       = azurerm_subnet.management.id
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = azurerm_public_ip.management.id
    }
}

resource "azurerm_windows_virtual_machine" "management" {
    name                    = "mgmt-vm01"
    location                = azurerm_resource_group.lab.location
    resource_group_name     = azurerm_resource_group.lab.name
    size                    = "Standard_B2s"
    admin_username          = "labadmin"
    admin_password          = "Lab@dmin1234!"

    network_interface_ids = [
        azurerm_network_interface.management.id
    ]

    os_disk {
        caching                 = "ReadWrite"
        storage_account_type    = "Standard_LRS"
    }

    source_image_reference {
        publisher   = "MicrosoftWindowsServer"
        offer       = "WindowsServer"
        sku         = "2022-Datacenter"
        version     = "latest"
    }
}
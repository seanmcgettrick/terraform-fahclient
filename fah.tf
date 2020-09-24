provider "azurerm" {
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "terraformrg" {
    name = "${var.resourcePrefix}-rg"
    location = var.location
}

resource "azurerm_virtual_network" "terraformnet" {
    name = "${var.resourcePrefix}-vnet"
    address_space = ["10.0.0.0/16"]
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name
}

resource "azurerm_subnet" "terraformsubnet" {
    name = "${var.resourcePrefix}-subnet"
    resource_group_name = azurerm_resource_group.terraformrg.name
    virtual_network_name = azurerm_virtual_network.terraformnet.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "terraformpublicip" {
    name = "${var.resourcePrefix}-public-ip"
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name
    allocation_method = "Dynamic"
    domain_name_label = var.dnsName
}

resource "azurerm_network_security_group" "terraformnsg" {
    name = "${var.resourcePrefix}-nsg"
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name
}

resource "azurerm_network_security_rule" "terraformsshrule" {
    name = "allow-ssh"
    priority = 1000
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.terraformrg.name
    network_security_group_name = azurerm_network_security_group.terraformnsg.name
}

resource "azurerm_network_security_rule" "terraformfahremoterule" {
    name = "allow-fahremote"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "36330"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.terraformrg.name
    network_security_group_name = azurerm_network_security_group.terraformnsg.name
}

resource "azurerm_network_security_rule" "terraformfahwebrule" {
    name = "allow-fahremote-web"
    priority = 1002
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.terraformrg.name
    network_security_group_name = azurerm_network_security_group.terraformnsg.name
}

resource "azurerm_network_interface" "terraformnic" {
    name = "${var.resourcePrefix}-nic"
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name

    ip_configuration {
        name = "${var.resourcePrefix}-ipconfig"
        subnet_id = azurerm_subnet.terraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.terraformpublicip.id
    }
}

resource "azurerm_network_interface_security_group_association" "terraformassociation" {
    network_interface_id = azurerm_network_interface.terraformnic.id
    network_security_group_id = azurerm_network_security_group.terraformnsg.id
}

resource "random_id" "randomId" {
    keepers = {
        resource_group = azurerm_resource_group.terraformrg.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "terraformstorageaccount" {
    name = "diag${random_id.randomId.hex}"
    resource_group_name = azurerm_resource_group.terraformrg.name
    location = var.location
    account_replication_type = "LRS"
    account_tier = "Standard"
}

resource "tls_private_key" "sshprivatekey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = "${tls_private_key.sshprivatekey.private_key_pem}" }

resource "azurerm_linux_virtual_machine" "terraformvm" {
    count = var.spotVm ? 0 : 1
    
    name = "${var.resourcePrefix}-vm"
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    size = var.vmSize

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    computer_name = "${var.resourcePrefix}-vm"
    admin_username = var.adminUser
    disable_password_authentication = true

    admin_ssh_key {
        username = var.adminUser
        public_key = tls_private_key.sshprivatekey.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.terraformstorageaccount.primary_blob_endpoint
    }
}

resource "azurerm_linux_virtual_machine" "terraformspotvm" {
    count = var.spotVm ? 1 : 0

    name = "${var.resourcePrefix}-spot-vm"
    location = var.location
    resource_group_name = azurerm_resource_group.terraformrg.name
    network_interface_ids = [azurerm_network_interface.terraformnic.id]
    size = var.vmSize

    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    computer_name = "${var.resourcePrefix}-vm"
    admin_username = var.adminUser
    disable_password_authentication = true

    admin_ssh_key {
        username = var.adminUser
        public_key = tls_private_key.sshprivatekey.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.terraformstorageaccount.primary_blob_endpoint
    }

    priority = "Spot"
    eviction_policy = "Deallocate"
    max_bid_price = var.spotVmMaxPrice
}

resource "azurerm_virtual_machine_extension" "terraformvmext" {
    count = var.spotVm ? 0 : 1
    name = "${azurerm_linux_virtual_machine.terraformvm[count.index].name}-fahclient-setup"
    virtual_machine_id = azurerm_linux_virtual_machine.terraformvm[count.index].id
    publisher = "Microsoft.Azure.Extensions"
    type = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/theonemule/fahclient-azure-vm/master/install.sh"],
            "commandToExecute": "bash install.sh --user='${var.fahUser}' --team='${var.fahTeam}' --passkey='${var.fahPasskey}' --password='${var.adminPassword}' --adminuser='${var.adminUser}'"
        }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "terraformspotvmext" {
    count = var.spotVm ? 1 : 0
    name = "${azurerm_linux_virtual_machine.terraformspotvm[count.index].name}-fahclient-setup"
    virtual_machine_id = azurerm_linux_virtual_machine.terraformspotvm[count.index].id
    publisher = "Microsoft.Azure.Extensions"
    type = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
        {
            "fileUris": ["https://raw.githubusercontent.com/theonemule/fahclient-azure-vm/master/install.sh"],
            "commandToExecute": "bash install.sh --user='${var.fahUser}' --team='${var.fahTeam}' --passkey='${var.fahPasskey}' --password='${var.adminPassword}' --adminuser='${var.adminUser}'"
        }
SETTINGS
}

output "https_url" { value = "https://${azurerm_public_ip.terraformpublicip.domain_name_label}.${azurerm_resource_group.terraformrg.location}.cloudapp.azure.com" }
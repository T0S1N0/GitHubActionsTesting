
# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  provider = azurerm.__alias_name__
}

# Create Azure Virtual Desktop resources

# Scale set
resource "azurerm_windows_virtual_machine_scale_set" "scale-set" {
  name                 = var.scale_set_name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  sku                  = "Standard_D2s_v3"
  instances            = 2
  admin_password       = "__localadmin_password__"
  admin_username       = "plexadm"
  computer_name_prefix = "wvd-__project__"
  provision_vm_agent   = true
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd-g2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  network_interface {
    name    = var.network_interface_name
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet.id
      # public_ip_address {
      #   name                = var.public_ip_name
      #   public_ip_prefix_id = azurerm_public_ip_prefix.public_ip_prefix.id
      # }
    }
  }
  provider = azurerm.__alias_name__
}

# Virtual Desktop Host Pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  name                     = var.hostpool_name
  friendly_name            = "wvd-__project__-__environment__-"
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  description              = "Acceptance Test: A pooled host pool - pooleddepthfirst"
  type                     = "Pooled"
  maximum_sessions_allowed = 5
  load_balancer_type       = "DepthFirst"
  scheduled_agent_updates {
    enabled = true
    schedule {
      day_of_week = "Saturday"
      hour_of_day = 2
    }
  }
  depends_on = [azurerm_resource_group.rg]
  provider   = azurerm.__alias_name__
}



resource "azurerm_virtual_desktop_host_pool_registration_info" "hostpool-registration" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = "2023-08-20T23:40:52Z"
  provider        = azurerm.__alias_name__
}

resource "time_rotating" "rotation-token" {
  rotation_days = 30
}

# Virtual Desktop Workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]
  provider            = azurerm.__alias_name__
}

# Virtual Desktop Workspace Application Group Association
resource "azurerm_virtual_desktop_workspace_application_group_association" "group_association" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.application_group.id
  depends_on           = [azurerm_virtual_desktop_application_group.application_group, azurerm_virtual_desktop_host_pool.hostpool]
  provider             = azurerm.__alias_name__
}

# Virtual Desktop Application Group
resource "azurerm_virtual_desktop_application_group" "application_group" {
  name                         = var.application_group_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg.name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.hostpool.id
  type                         = "Desktop"
  friendly_name                = "__project__-wvd-__environment__"
  default_desktop_display_name = "__project__-wvd"
  description                  = "Dra VPN: An application group"
  depends_on                   = [azurerm_virtual_desktop_host_pool.hostpool]
  provider                     = azurerm.__alias_name__
}

data "azuread_groups" "groups" {
  object_ids = ["1c82f4b0-8612-4b78-966f-d5032607d881", "6811f37a-75f3-49b1-9c9f-68f1f23d31e8"]
}

resource "azurerm_role_assignment" "desktop-virtualization-user" {
  count               = length(data.azuread_groups.groups.object_ids)
  scope               = azurerm_resource_group.rg.id
  role_definition_name = "Desktop Virtualization User"
  principal_id        = data.azuread_groups.groups.object_ids[count.index]
  provider             = azurerm.__alias_name__
}

resource "azurerm_role_assignment" "desktop-user-login" {
  count               = length(data.azuread_groups.groups.object_ids)
  scope               = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine User Login"
  principal_id        = data.azuread_groups.groups.object_ids[count.index]
  provider             = azurerm.__alias_name__
}

# Virtual Network
resource "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network_name
  address_space       = ["10.162.0.0/28"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = ["10.200.10.20", "10.200.10.21"]
  depends_on          = [azurerm_resource_group.rg]
  provider            = azurerm.__alias_name__
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.162.0.0/28"]
  depends_on           = [azurerm_virtual_network.virtual_network]
  provider             = azurerm.__alias_name__
}

# # Public IP Prefix
# resource "azurerm_public_ip_prefix" "public_ip_prefix" {
#   name                = var.public_ip_prefix
#   prefix_length       = 28
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
#   depends_on          = [azurerm_resource_group.rg]
#   provider            = azurerm.__alias_name__
# }

resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  provider = azurerm.__alias_name__
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  provider                  = azurerm.__alias_name__
}

#Peerings

data "azurerm_resource_group" "rg_dwi" {
  provider = azurerm.dwi
  name     = "plxneteu01-rg"
}

data "azurerm_virtual_network" "vnetDC" {
  name                = "plxeu01-vnet"
  resource_group_name = data.azurerm_resource_group.rg_dwi.name
  provider            = azurerm.dwi
}

resource "azurerm_virtual_network_peering" "fromDraWvdToDCwe" {
  name                      = var.peer_to_dc
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.virtual_network.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnetDC.id
  depends_on = [
    data.azurerm_virtual_network.vnetDC,
    azurerm_virtual_network.virtual_network
  ]
  provider = azurerm.__alias_name__
}

resource "azurerm_virtual_network_peering" "fromDcToDraWvd" {
  name                      = var.peer_from_dc
  resource_group_name       = data.azurerm_resource_group.rg_dwi.name
  virtual_network_name      = data.azurerm_virtual_network.vnetDC.name
  remote_virtual_network_id = azurerm_virtual_network.virtual_network.id
  depends_on = [
    data.azurerm_virtual_network.vnetDC,
    azurerm_virtual_network.virtual_network
  ]
  provider = azurerm.dwi
}
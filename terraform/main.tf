terraform {
  backend "azurerm" {
    resource_group_name   = "Mo-IngeniumCode"
    storage_account_name  = "tfstore"
    container_name        = "statefile"
    key                   = "akstest.tfstate"
  }
}
provider "azurerm"{
 features {}
}
variable "appID" {
  type = string
  default = "value"
}
variable "appPW" {
  type = string
  default = "value"
}
#Create the subnet for AKS with 500+ IPs
data "azurerm_subnet" "bsp_subnet"{
 name = "Mo-IngeniumCode-Do"
 virtual_network_name = "VNETUSW"
 resource_group_name = "VNETUSW"
}

#Create the RG
resource "azurerm_resource_group" "prod_aks_rg" {
  name     = "aks-test1"
  location = "westus2"
  tags = {
     "terraformed" = "true",
     "CreatedBy": "Mo Figueroa"
  }
}

data "azurerm_private_dns_zone" "prodaksdns" {
  name                = "privatelink.westus2.azmk8s.io"
  resource_group_name = "aks-test1"
}

resource "azurerm_kubernetes_cluster" "prod_aks" {
  name                = "akstest1"
  location            = azurerm_resource_group.prod_aks_rg.location
  resource_group_name = azurerm_resource_group.prod_aks_rg.name
  dns_prefix          = "akstest1"
  private_cluster_enabled = true
  private_dns_zone_id     = data.azurerm_private_dns_zone.prodaksdns.id
  private_cluster_public_fqdn_enabled = false
  

  network_profile {
    network_plugin = "azure"
  }

  default_node_pool {
    name       = "akstestnp1"
    node_count = 3
    vm_size    = "Standard_D8s_v3"
    vnet_subnet_id = data.azurerm_subnet.bsp_subnet.id
  }

  service_principal {
    client_id = var.appID
    client_secret = var.appPW
  }


  tags = {
     "terraformed" = "true",
     "CreatedBy": "Mo Figueroa"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.prod_aks_eck.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.prod_aks_eck.kube_config_raw

  sensitive = true
}
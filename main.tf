terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  skip_provider_registration = true
}

provider "azuread" {
  features {}
}

provider "kubernetes" {
  #config_path = "~/.kube/config"
  load_config_file       = false
}

provider "kubectl" {
  load_config_file = false
  # config_path = "kubeconfig"
}


# Create a resource group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group
  location = var.location
}

# Create Vnet and subnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.1.0/24"]
  depends_on = [azurerm_virtual_network.vnet]
}  


# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "my-aks-dns"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    vnet_subnet_id  = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group}/providers/Microsoft.Network/virtualNetworks/${var.vnet}/subnets/${var.subnet}"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  depends_on = [
    azurerm_subnet.aks_subnet
  ]
}

data "kubectl_path_documents" "docs" {
    pattern = "*.yml"
}

resource "null_resource" "connect" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = "${local.mongo}"
  }
}


locals {
  depends_on = [null_resource.provision_pods]
  #client_cert = powershell("kubectl config view --raw -o jsonpath='{.users[].user.client-certificate-data}'")
  #client_cert = local.local_command_result
  user = "$${kubectl config view --raw -o jsonpath='{.users[].name}'}"
  local_command_result = "kubectl get po | grep mongo | cut -d ' ' -f 1"
  mongo =  "az aks get-credentials --overwrite-existing --name ${var.aks_name} --resource-group ${var.resource_group} --subscription ${var.subscription_id} --admin" # data.external.command_result.result
}
resource "null_resource" "provision_pods" {
  depends_on = [null_resource.connect]
  provisioner "local-exec" {
    command = "kubectl apply -f mongo.yml; kubectl apply -f 'app&svc.yml'; sleep 60;"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "null_resource" "test" {
  depends_on = [null_resource.provision_pods]
  provisioner "local-exec" {
    command = "write-host ${local.mongo}"
    interpreter = ["PowerShell", "-Command"]
  } 
}


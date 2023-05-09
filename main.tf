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
  config_path = "~/.kube/config"
}

#resource "azurerm_resource_provider_registration" "provider" {
#  name = "Microsoft.Kubernetes"
#  feature {
#    name       = "AKS-DataPlaneAutoApprove"
#    registered = true
#  }
#}

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
    pattern = "TEST/*.yml"
}

resource "kubectl_manifest" "app" {    
   #for_each  = toset(data.kubectl_path_documents.docs.documents)
   count     = length(data.kubectl_path_documents.docs.documents)
   yaml_body = element(data.kubectl_path_documents.docs.documents, count.index)
   depends_on = [azurerm_kubernetes_cluster.aks]
}

output "yaml_body" {
    description = "The YAML files found"
    value       = kubectl_manifest.app[*].yaml_body
    sensitive = true
}

resource "null_resource" "copy_file_to_pod" {
  provisioner "local-exec" {
  command = "kubectl cp ./TEST/app/* default/apples-app[*]:/app/"
  }
  
  depends_on = [kubectl_manifest.app[1]]

  # Trigger the provisioner every time the namespace or pod name changes
  triggers = {
    namespace = "default"
    pod_name = "apples-app*"
  }
}

resource "null_resource" "execute_command" {
  provisioner "local-exec" {
  command = "kubectl get pods -o name | xargs -I{} kubectl exec {} -- node server.js && npm run start && npm ls --depth=0"
  }
  
  depends_on = [kubectl_manifest.app[1]]

  # Trigger the provisioner every time the namespace or pod name changes
  triggers = {
    namespace = "default"
    pod_name = "apples-app*"
  }
}

resource "null_resource" "example" {
  depends_on = [kubectl_manifest.app[1]]
  provisioner "local-exec" {
    command = "kubectl get pods -l app=apples-app -o jsonpath='{.items[1].metadata.name}' > pod_name.txt"
  }
}

output "pod_name" {
  value = null_resource.example
  #value = "${trim(file("C:/Users/Administrator.KOBI-LAT5480/Documents/Provisioning/TEST/pod_name.txt"), " ")}"
  depends_on = [kubectl_manifest.app]
}

output "kubernetes_pod" {
  description = "The created pod names"
  value = kubectl_manifest.app[*].yaml_body
  sensitive = true
}
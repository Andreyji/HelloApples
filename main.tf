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
    pattern = "*.yml"
}

resource "null_resource" "connect" {
  depends_on = [azurerm_kubernetes_cluster.aks]
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = "${local.mongo}"
  }
}

#resource "null_resource" "connect" {
#  depends_on = [azurerm_kubernetes_cluster.aks]
#  provisioner "local-exec" {
#    command = "az aks get-credentials --resource-group=${var.resource_group} --name=${var.aks_name} --subscription=${var.subscription_id} --overwrite-existing;"
#    interpreter = ["PowerShell", "-Command"]
#  }
#}

locals {
  depends_on = [null_resource.provision_pods]
  #client_cert = powershell("kubectl config view --raw -o jsonpath='{.users[].user.client-certificate-data}'")
  #client_cert = local.local_command_result
  user = "$${kubectl config view --raw -o jsonpath='{.users[].name}'}"
  local_command_result = "kubectl get po | grep mongo | cut -d ' ' -f 1"
  mongo =  "az aks get-credentials --overwrite-existing --name ${var.aks_name} --resource-group ${var.resource_group} --subscription ${var.subscription_id} --admin" # data.external.command_result.result
}

#resource "null_resource" "example" {
#  provisioner "local-exec" {
#    command = "kubectl get pods -o jsonpath='{.items[0].metadata.name}'"
#    interpreter = ["bash", "-c"]
#  }
#}
#
#  provisioner "local-exec" {
#    command = "echo ${self.id} > /tmp/null_resource_id"
#    interpreter = ["bash", "-c"]
#  }
#}

#resource "kubectl_manifest" "app" {
#   depends_on = [null_resource.connect]
#   #for_each  = toset(data.kubectl_path_documents.docs.documents)
#   count     = length(data.kubectl_path_documents.docs.documents)
#   yaml_body = element(data.kubectl_path_documents.docs.documents, count.index)
#}

#output "yaml_body" {
#    description = "The YAML files found"
#    value       = kubectl_manifest.app[*].yaml_body
#    sensitive = true
#}


resource "null_resource" "provision_pods" {
  depends_on = [null_resource.connect]
  provisioner "local-exec" {
    command = "kubectl apply -f mongo.yml; kubectl apply -f 'app&svc.yml'; sleep 60;"
    interpreter = ["PowerShell", "-Command"]
  }
}

# resource "null_resource" "execute_conn" {
#   depends_on = [azurerm_kubernetes_cluster.aks]
#   provisioner "local-exec" {
#     environment = {
#     PSModulePath = "$env:PSModulePath"
#     }
#     command     = "powershell -Command \"kubectl get po | grep mongo | cut -d ' ' -f 1 > out.txt\""
#     interpreter = ["PowerShell", "-Command"]
#   }
# }

#data "external" "command_result" {
#  program = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "script.ps1 | convertto-json"]
#}

resource "null_resource" "test" {
  depends_on = [null_resource.provision_pods]
  provisioner "local-exec" {
    command = "write-host ${local.mongo}"
    interpreter = ["PowerShell", "-Command"]
  } 
}
# resource "null_resource" "copy_conf" {
#   depends_on = [null_resource.provision_pods]
#   provisioner "file" {
#     source = "mongo.conf"
#     destination = "/data/confdb/"
#   }
 # connection {
 #   host = "${local.mongo}"
 # }
  #command = "kubectl get po | grep mongo | cut -d ' ' -f 1; $mip = kubectl describe po $mon | grep ' IP:' | awk '{print $3}'; kubectl.exe cp data.json $mon':/data/db/'; kubectl.exe cp mongo.conf $mon':/etc/mongod.conf.orig';"
# }

# resource "null_resource" "copy_db" {
#   depends_on = [null_resource.provision_pods]
#   provisioner "file" {
#     source = "data.json"
#     destination = "/data/db/"
#     ENV = "kubectl get po | grep mongo | cut -d \" \" -f 1"
#   }
#  
#   connection {
#     host = "$MON"
#   }
# }

# resource "null_resource" "initiate_db" {
#   depends_on = [null_resource.copy_conf]
#   provisioner "remote-exec" {
#     connection {
#       host = local.mongo
#       }
#     inline = ["mongod -f /data/configdb/mongo.conf; write-host '2. DB is up'"]
#   }
# }

#resource "null_resource" "exec_script" {
#  depends_on = [null_resource.provision_pods]
#  provisioner "local-exec" {
#    command = "script.ps1"
#    interpreter = ["PowerShell", "-File"]
#    environment = {
#      MON = "kubectl get po | grep mongo | cut -d \" \" -f 1"
#    }
#  }
#}


#output "pod_name" {
#  value = null_resource.example
#  #value = "${trim(file("C:/Users/Administrator.KOBI-LAT5480/Documents/Provisioning/pod_name.txt"), " ")}"
#  depends_on = [kubectl_manifest.app]
#}

#output "kubernetes_pod" {
#  description = "The created pod names"
#  value = kubectl_manifest.app[*].yaml_body
#  sensitive = true
#}

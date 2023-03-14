terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Create a resource group
resource "azurerm_resource_group" "aks" {
  name     = var.resource_group
  location = var.location
}

# Create Vnet and subnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
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
}

############

provider "kubernetes" {
  config_context_cluster = "mycluster"
}

resource "kubernetes_secret" "mongo" {
  metadata {
    name = "mongodb-auth"
  }

  data = {
    "mongodb-root-password" = base64encode("${var.mongo_pass}")
  }
}

resource "kubernetes_config_map" "mongo" {
  metadata {
    name = "mongodb-config"
  }

  data = {
    "mongod.conf" = templatefile("${path.module}/mongod.conf.tpl", {})
  }
}

resource "kubernetes_deployment" "mongo" {
  metadata {
    name = "mongodb"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          app = "mongodb"
        }
      }

      spec {
        container {
          name  = "mongodb"
          image = "mongo:latest"

          env {
            name  = "MONGO_INITDB_ROOT_USERNAME"
            value = "admin"
          }

          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mongo.metadata[0].name
                key  = "mongodb-root-password"
              }
            }
          }

          volume_mount {
            name       = "mongodb-data"
            mount_path = "/data/db"
          }

          volume_mount {
            name       = "mongodb-config"
            mount_path = "/etc/mongod.conf"
            sub_path   = "mongod.conf"
          }
        }

        volume {
          name = "mongodb-data"
          persistent_volume_claim {
            claim_name = "mongodb-data"
          }
        }

        volume {
          name = "mongodb-config"
          config_map {
            name = kubernetes_config_map.mongo.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongo" {
  metadata {
    name = "mongodb"
  }

  spec {
    selector = {
      app = kubernetes_deployment.mongo.spec.0.template.0.metadata.0.labels.app
    }

    port {
      port        = 27017
      target_port = 27017
    }
  }
}

data "local_file" "data" {
  filename = "${path.module}/data.json"
}

resource "null_resource" "mongo_data" {
  triggers = {
    data_file = data.local_file.data.content
  }

  depends_on = [
    kubernetes_deployment.mongo
  ]

  provisioner "local-exec" {
    command = "echo '${data.local_file.data.content}' > /data/db/data.json"
  }
}

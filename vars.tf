variable "subscription_id" {
  type        = string
  description = "The ID of the Azure subscription to use."
  default 	  = "[ENTER_VALUE]"
}

variable "client_id" {
  type        = string
  description = "The ID of the Service Principal used for authentication."
  default 	  = "[ENTER_VALUE]"
}

variable "client_secret" {
  type        = string
  description = "The secret associated with the Service Principal."
  default 	  = "[ENTER_VALUE]"
}

variable "tenant_id" {
  type        = string
  description = "The ID of the Azure AD tenant."
  default 	  = "[ENTER_VALUE]"
}

variable "location" {
  type        = string
  description = "The location for Azure resources."
  default 	  = "East US"
}

variable "resource_group" {
  type		  = string
  description = "The name of the resource group you would like to use."
  default	  = "[ENTER_VALUE]"
}

variable "aks_name" {
  type		  = string
  description = "The name of the AKS you would like to use."
  default	  = "my_aks_cluster"
}

variable "vnet" {
  type		  = string
  description = "The name of the v-net you would like to use."
  default	  = "my-vnet"
}

variable "subnet" {
  type		  = string
  description = "The name of the subnet you would like to use."
  default	  = "aks_subnet"
}


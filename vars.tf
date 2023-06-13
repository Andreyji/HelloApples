variable "subscription_id" {
  type        = string
  description = "The ID of the Azure subscription to use."
  default 	  = "77f32f18-c9f5-49b3-aa7a-c874811a59ec"
}

variable "client_id" {
  type        = string
  description = "The ID of the Service Principal used for authentication."
  default 	  = "d7680f93-6e83-49a0-b679-f6e13f8b2081"
}

variable "client_secret" {
  type        = string
  description = "The secret associated with the Service Principal."
  default 	  = "g1K8Q~toRhOtV4JsRTxgK7eEsc~wKG-_O.MuzaI5"
}

variable "tenant_id" {
  type        = string
  description = "The ID of the Azure AD tenant."
  default 	  = "86601a9f-7015-4b7e-b0ce-3917312ed604"
}

variable "location" {
  type        = string
  description = "The location for Azure resources."
  default 	  = "East US"
}

variable "resource_group" {
  type		  = string
  description = "The name of the resource group you would like to use."
  default	  = "newRG"
}

variable "aks_name" {
  type		  = string
  description = "The name of the AKS you would like to use."
  default	  = "my-aks-cluster"
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




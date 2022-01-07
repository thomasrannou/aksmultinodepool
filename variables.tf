# ======================================================================================
# Variables Azure Kubernetes Service
# ======================================================================================
variable "aks-resource-group-name" { 
    description = "Nom du resource group contenant AKS"
}

variable "aks-resource-group-location" { 
    description = "Location du resource group contenant AKS"
    default     = "West Europe"
}

variable "aks-cluster-name" {
    description	= "Nom du cluster Kubernetes"
}

variable "aks-cluster-sp-client-id" {
    description	= "Client id du service principal utilisé par le cluster Kubernetes"
}

variable "aks-cluster-sp-client-secret" {
    description	= "Client secret du service principal utilisé par le cluster Kubernetes"
}
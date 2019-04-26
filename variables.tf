###################
# SPN
######################
variable "client_id" {}
variable "client_secret" {}

#########################
# RBAC and AAD
########################

variable "tenant_id" {}
variable "rbac_server_app_id" {}
variable "rbac_server_app_secret" {}
variable "rbac_client_app_id" {}


variable "vault_uri" {	  
  default = "https://pacy-aks-key-vault.vault.azure.net/"
}

variable "agent_count" {
    default = 2
}

variable "aks_username" {}
variable "ssh_public_key" {
    default = "~/.ssh/kube-devolab_id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable cluster_name {
    default = "Devo-k8s-aks-tsp"
}

variable resource_group_name {
    default = "RG-azure-k8stsp"
}

variable location {
    default = "West Europe"
}

variable log_analytics_workspace_name {
    default = "loganalytics-aks-tsp"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}
variable "key_tags" {
  type = "map"
  default {
    Environment = "node_username_vault_secret"
  }
}

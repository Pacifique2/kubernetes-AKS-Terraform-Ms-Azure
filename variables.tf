variable "client_id" {}
variable "client_secret" {}

variable "agent_count" {
    default = 2
}

variable "username" {
  default = "pacifique"
}
variable "ssh_public_key" {
    default = "~/.ssh/kube-devolab_id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable cluster_name {
    default = "k8stsp"
}
/*
variable resource_group_name {
    default = "RG-azure-k8stsp"
}
*/
variable location {
    default = "West Europe"
}

variable log_analytics_workspace_name {
    default = "loganalyticswktsp"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "westeurope"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}

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


variable "azure_key_vault_url" {}

variable "aks_worker_nodes_count" {
  default = 2
}
variable "aks_username" {}







































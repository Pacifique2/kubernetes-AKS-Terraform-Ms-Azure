provider "azurerm" {
    version = "~>1.5"
}

terraform {
    backend "azurerm" {}
}


module "aks-cluster" {
  source = "./rbac-enabled-aks-cluster"
  client_id = "${var.client_id}" 
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}" 
  rbac_server_app_id = "${var.rbac_server_app_id}"
  rbac_server_app_secret = "${var.rbac_server_app_secret}"
  rbac_client_app_id = "${var.rbac_client_app_id}"
  aks_username = "${var.aks_username}"
  vault_uri = "${var.azure_key_vault_url}"
  agent_count = "${var.aks_worker_nodes_count}"
}

module "helm-manager-setup" {
  source = "./helm-k8s-pkg-manager"
  aks_id = "${module.aks-cluster.aks_id}"
}

module "ingress-controller" {
  source = "./ingress-controller"
  helm_rs_id = "${module.helm-manager-setup.helm_rs_id}"
}


module "monitoring" {
  source = "./monitoring"
  ingress_controller_id = "${module.ingress-controller.ingress_controller_id}"
}



/*
data "terraform_remote_state" "foo" {
  backend = "azurerm"
  config = {
    storage_account_name = ""
    container_name       = ""
    key                  = "tfstate"
  }
}
*/











































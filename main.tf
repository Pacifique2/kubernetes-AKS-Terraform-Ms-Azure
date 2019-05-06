provider "azurerm" {
    #version = "~>1.5"
}
/*
terraform {
    backend "azurerm" {}
}

data "terraform_remote_state" "foo" {
  backend = "azurerm"
  config = {
    storage_account_name = "akspacysa"
    container_name       = "tfstate"
    key                  = "devolab.microsoft.tfstate"
  }
}*/
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
  grafana_dns_name = "${var.ingress_dns_name}"
  aks_rg_name = "${module.aks-cluster.aks_rg_name}"
  aks_cluster_name = "${module.aks-cluster.aks_cluster_name}"

}


module "monitoring" {
  source = "./monitoring"
  ingress_controller_id = "${module.ingress-controller.ingress_controller_id}"
  dspl_aks_id = "${module.aks-cluster.aks_id}"
  dspl_helm_id = "${module.helm-manager-setup.helm_rs_id}"
  
}

resource "null_resource" "test" {
  depends_on = ["module.monitoring"]
  provisioner "local-exec" {
    command="echo done"
  }  
}


/*
data "terraform_remote_state" "foo" {
  backend = "azurerm"
  config = {
    storage_account_name = "akspacysa"
    container_name       = "aks-tfstate"
    key                  = "devolab.microsoft.tfstate"
  }
}
*/











































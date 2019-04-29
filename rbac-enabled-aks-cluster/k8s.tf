
resource "azurerm_resource_group" "k8s" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}


/*
resource "azurerm_storage_account" "testsa" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.k8s.name}"
  location                 = "${azurerm_resource_group.k8s.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "Devoteam_k8s"
  }
}




data "azurerm_resource_group" "k8s" {
  name = "NetworkWatcherRG"
}
*/
## Generate Random String	
/*
resource "random_string" "vm_password" {
  length      = 14	  
  min_upper   = 2	
  min_lower   = 2	
  min_numeric = 2	  
  min_special = 2
  #count           = "${var.agent_count}"
}
*/
## Create the secret	
resource "azurerm_key_vault_secret" "vm_secret" {
  name      = "vm-user-secret"	
  value =   "${var.aks_username}" 
  # value     = "${random_string.vm_password.result[count.index]}"
  vault_uri = "${var.vault_uri}"	
  tags      = "${var.key_tags}"	
}

resource "azurerm_log_analytics_workspace" "test" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}


resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.cluster_name}"
    location            = "${azurerm_resource_group.k8s.location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    dns_prefix          = "${var.dns_prefix}"
    depends_on          = ["azurerm_key_vault_secret.vm_secret"]
    linux_profile {
        #admin_username = "${var.username}"
        admin_username = "${azurerm_key_vault_secret.vm_secret.value}" # Use the secret created earlier
        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "Standard_DS1_v2"
        os_type         = "Linux"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }
   
    role_based_access_control {
      azure_active_directory {
              server_app_id     = "${var.rbac_server_app_id}"
              server_app_secret = "${var.rbac_server_app_secret}"
              client_app_id     = "${var.rbac_client_app_id}"
              tenant_id         = "${var.tenant_id}"
      }
      enabled = true
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
        }
    }

    tags {
        Environment = "Development"
    }
}


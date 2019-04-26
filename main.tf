provider "azurerm" {
    version = "~>1.5"
}

terraform {
    backend "azurerm" {}
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

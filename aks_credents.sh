#!/usr/bin

set -e

echo "seting up authethication variables"
############################################################################
echo "azure storage account access key"
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name pacy-aks-key-vault --query value -o tsv)

#############################################################################

# export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --name ARM-SUBSCRIPTION-ID --vault-name pacy-aks-key-vault --query value -o tsv)	
#export ARM_CLIENT_ID=$(az keyvault secret show --name ARM-CLIENT-ID --vault-name pacy-aks-key-vault --query value -o tsv)	
# export ARM_CLIENT_SECRET=$(az keyvault secret show --name ARM-CLIENT-SECRET --vault-name pacy-aks-key-vault --query value -o tsv)	
# export ARM_TENANT_ID=$(az keyvault secret show --name ARM-TENANT-ID --vault-name pacy-aks-key-vault --query value -o tsv)

echo done

echo "aks vms common username"
# export TF_VAR_aks_username="aks_node_username" defined on the terminal
############################################################################
echo "Exporting both the app server and client server environment variables"

export TF_VAR_client_id=$(az keyvault secret show --name ARM-CLIENT-ID --vault-name pacy-aks-key-vault --query value -o tsv)
export TF_VAR_client_secret=$(az keyvault secret show --name ARM-CLIENT-SECRET --vault-name pacy-aks-key-vault --query value -o tsv)

###########################################################################

export TF_VAR_rbac_server_app_id=$(az keyvault secret show --name RBAC-SERVER-APP-ID --vault-name pacy-aks-key-vault --query value -o tsv)
export TF_VAR_rbac_server_app_secret=$(az keyvault secret show --name RBAC-SERVER-APP-PASSWORD --vault-name pacy-aks-key-vault --query value -o tsv)
export TF_VAR_rbac_client_app_id=$(az keyvault secret show --name RBAC-CLIENT-APP-ID --vault-name pacy-aks-key-vault --query value -o tsv)
export TF_VAR_tenant_id=$(az keyvault secret show --name AZURE-TENANT-ID --vault-name pacy-aks-key-vault --query value -o tsv)

echo done

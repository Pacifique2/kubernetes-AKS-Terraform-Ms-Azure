#!/usr/bin

set -e

echo "To access images stored in ACR, we have to grant the AKS service principal the correct rights to pull images from ACR."
export acr_id=$(az acr show --resource-group NetworkWatcherRG --name devoteamTsp --query "id" --output tsv)
az role assignment create --assignee ${TF_VAR_client_id} --scope ${acr_id} --role acrpull

echo done

#!/usr/bin

set -e

echo "Creating azure container registry"

# az acr create --resource-group NetworkWatcherRG --name devoteamTsp --sku Basic
# az acr login --name devoteamTsp

echo "tagging the built app container"

echo "list the container image before being tagged"
sudo docker images

echo "list the acrLoginServer to be used when tagging the app container image"
echo "To get the login server address, use the az acr list command and query for the loginServer as follow:"
export acrLoginServer=$(az acr list --resource-group NetworkWatcherRG --query "[].{acrLoginServer:loginServer}" --output tsv)

echo "Tag the container image as follow:"

sudo docker tag azure-vote-front ${acrLoginServer}/azure-vote-front:v2
echo "Tagged"
echo "Now, the azure-vote-front container image can be used with ACR"

echo "Verify that the tags are applied,"
sudo docker images

echo "push the tagged image to your ACR instance"
sudo docker push ${acrLoginServer}/azure-vote-front:v2
echo "return a list of images that have been pushed to your ACR instance"
az acr repository list --name devoteamTsp --output table
echo "To see the tags for the created image"
az acr repository show-tags --name devoteamTsp --repository azure-vote-front --output table


echo "Now we can prepare the application for a kubernetes deployment"

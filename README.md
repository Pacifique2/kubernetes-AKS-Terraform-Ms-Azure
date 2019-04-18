# kubernetes-AKS-Terraform-Ms-Azure
Tested terraform implementation of the kubernetes solution that is managed by Microsoft Azure public cloud.

# Make sure that you have created a service principal before testing this solution
see the link below for more information:\
https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest

# Make sure that you have a created azure storage account
see the link below for more information:\
https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account?tabs=azure-cli
## Create a container in the created azure storage account for storing the terraform state file.
This is benefial when working in a team for the fact that the terraform state file would be accessible by the whole team.
this example below shows how a storage container can be created within azure by using the CLI.\
**az storage container create -n tfstate --account-name <YourAzureStorageAccountName> --account-key <YourAzureStorageAccountKey>**

# Create the Kubernetes cluster
## run 
**terraform init -backend-config="storage_account_name=<YourAzureStorageAccountName>" -backend-config="container_name=tfstate" -backend-config="access_key=<YourStorageAccountAccessKey>" -backend-config="key=give_container_access_key"**\
On a termnal, initialize Terraform (replace the <YourAzureStorageAccountName> and <YourAzureStorageAccountAccessKey> placeholders with the appropriate values for your Azure storage account).\
see microsoft azure documentations for more information.

## Export your service principal credentials like below
export TF_VAR_client_id=<your-client-id>\
export TF_VAR_client_secret=<your-client-secret>\
where <your-client-id> and <your-client-secret> placeholders with the appId and password values associated with your service principal, respectively.

## Run the **terraform plan** command to create the Terraform plan that defines the infrastructure elements like below:
**terraform plan -out out.plan**
## Run the terraform apply command to apply the plan to create the Kubernetes cluster. 
**terraform apply out.plan**
# Test the Kubernetes cluster
## Get the Kubernetes configuration from the Terraform state and store it in a file that kubectl can read.

echo "$(terraform output kube_config)" > ./azurek8s
## Set an environment variable so that kubectl picks up the correct config.
export KUBECONFIG=./azurek8s
## Verify the k8s cluster
kubectl get nodes



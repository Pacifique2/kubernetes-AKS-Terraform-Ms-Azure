# kubernetes-AKS-Terraform-Ms-Azure with enabled RBAC with Azure Active Directory
Tested terraform implementation of the kubernetes solution that is managed by Microsoft Azure public cloud.

This peoject will start by creating Azure service principal then Azure AD client and server apps. Then we’ll create an AKS cluster configured with AAD. And we’ll finish by creating the Role and RoleBinding kubernetes manifest files.

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
  
# Create a server app and a client app within Azure Active Directory

To do so, you should follow all the necessary steps as described in the link below:
**https://docs.microsoft.com/fr-fr/azure/aks/azure-ad-integration**

# Use Azure Key Vault and terraform key vault to securely carry out the resources provionning with terraform
Create two scripts as follow:

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


# Configure Kubernetes RBAC

Having used RBAC and Azure key vault service to securely deploy the cluster and then secure the deployed cluster with Azure Active Directory, wee need to create Role/RoleBinding, ClusterRole/ClusterRoleBinding object using the Kubernetes API to give access to our Azure Active Directory users and groups so that they can remotely interact with the deployed AKS cluster with respect to their access rights.

To do that, weneed to connect to the cluster. An administrator Kubernetes configuration file can be obtained by using the Azure CLI:\
**az aks get credentials -n CLUSTER-NAME -g RESOURCE-GROUP-NAME --admin**

The repository contains a simple ClusterRoleBinding object definition file that will make sure that the Azure Active Directory user johndoe@jcorioland.onmicrosoft.com get the role that will be assigned to him.
Let’s create the Role which will define access to certain resources while assigning the role to a user. We created a bash script that does applies a role to a user by using a RoleBinding.

We can update this first cluster role binding and apply it using a bash script as show in the link below:\

# verify that both the role and role bindings have been created for the user pacifique
kubectl get roles\
kubectl get rolebindings
The created role and rolebinding should be displayed on the screen.

**kubectl apply -f k8s-rbac/cluster-admin-rolebinding.yaml**

# Connect to the cluster using RBAC and Azure AD
Once all you RBAC objects are defined in Kubernetes, you can get a Kubernetes configuration file that is not admin-enabled using the az **aks get-credentials command without the --admin flag**

az aks get credentials -n CLUSTER_NAME -g RESOURCE_GROUP_NAME
When you are going to use kubectl you are going to be asked to use the Azure Device Login authentication first:

**kubectl get nodes**





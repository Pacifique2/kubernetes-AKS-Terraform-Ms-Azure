
# echo "Setting the helm charts client and server for both apps and services deployments"
resource "null_resource" "helm_set_up" {
  provisioner "local-exec" {
    command=<<EOT
      echo "${var.aks_id}"
      echo "Fetching aks admin user credentials for later helm set up"
      az aks get-credentials -n Devo-k8s-aks-tsp -g RG-azure-k8stsp --admin
      echo "setting up the tiller as helm server within the aks cluster"
      kubectl create serviceaccount tiller --namespace kube-system
      kubectl create -f helm-k8s-pkg-manager/tiller-clusterrolebinding.yaml
      helm init --service-account tiller
      helm init --upgrade --service-account tiller
      sleep 50
      kubectl --namespace kube-system get pods | grep tiller
      helm ls
      echo "done configuring and installing the helm kubernetes package manager"
    EOT
  }

}

#  kubectl create -f helm-k8s-pkg-manager/clusterrole.yaml
################################################################################


















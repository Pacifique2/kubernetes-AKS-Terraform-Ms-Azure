# echo "Setting up both prometheus and grafana"


resource "null_resource" "display_ids" {
  provisioner "local-exec" {
    command=<<EOT
      echo "${var.dspl_aks_id}"
      echo "${var.ingress_controller_id}"
    EOT
  }
  provisioner "local-exec" {
    command="echo '${var.dspl_helm_id}'"
  }
  provisioner "local-exec" {
    command="echo '${var.ingress_controller_id}'"
  }
}

resource "null_resource" "prometheus_grafana" {
  depends_on = ["null_resource.display_ids"]
  provisioner "local-exec" {
    command=<<EOT
      kubectl apply -f monitoring/dashboard-sa-binding.yaml
      echo "Installing prometheus with helm charts and rbac enabled"
      helm install --name=prometheus stable/prometheus --namespace monitoring --set rbac.create=true
      echo "Use Helm to install grafana"
      helm install stable/grafana --set persistence.enabled=true --set persistence.accessModes={ReadWriteOnce} --set persistence.size=8Gi -n grafana --namespace monitoring
      echo "Export prometheus server pod's name and set up its local dashboard access"
      #export POD_NAME_PMTUS=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
      echo "Export grafana pod's name and set up its local dashboard access"
      #export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
      echo "Retrieve the grafana admin user password"
      export GRAFANA_ADMIN_PASS=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
      echo "done setting up a monitoring solution on aks based on prometheus and grafana"
    EOT
  }
}

# An ingress controller has been configured 
# let us set up a certificate management solution
################################################################################
# Exposing both prometheus and grafana dashboards with nginx ingress controller
################################################################################
# 1: 
#let us install the cert-manager controller in our aks RBAC-enabled cluster, we use helm.
# this cert manager will automatically manage cert issuers to provide certs that will be used
# by the ingress controller when creating traffic routes to both grafana and prometheus hosts
###########################################################################################

resource "null_resource" "cert_manager_set_upp" {
  depends_on = ["null_resource.display_ids","null_resource.prometheus_grafana"]
  provisioner "local-exec" {
    command=<<EOT
      echo "Install the CustomResourceDefinition resources separately"
      kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml
      echo "Create the namespace for cert-manager"
      kubectl create namespace cert-manager
      echo "Label the cert-manager namespace to disable resource validation"
      kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
      echo "Add the Jetstack Helm repository"
      helm repo add jetstack https://charts.jetstack.io
      echo "Update your local Helm chart repository cache"
      helm repo update
      echo "Install the cert-manager Helm chart"
      helm install --name cert-manager --namespace cert-manager --version v0.7.0 jetstack/cert-manager
      echo "for more information, see the cert manager project on github as show on the link below"
      echo "https://github.com/jetstack/cert-manager"
    EOT
  }
}

#######################################################################################
# Create a CA cluster issuer
###########################################
# Before certificates can be issued, cert-manager requires an Issuer or ClusterIssuer resource. 
#These Kubernetes resources are identical in functionality, 
#however Issuer works in a single namespace, and ClusterIssuer works across all namespaces.
########################################
# So let us create a clusterIssuer

resource "null_resource" "cert_cluster_issuer" {
  depends_on = ["null_resource.cert_manager_set_upp"]
  provisioner "local-exec" {
    command=<<EOT
      echo "Creating a cluster issuer resource"
      kubectl apply -f monitoring/cluster-issuer.yaml
      echo "Create an ingress route for both grafana and prometheus servers"
      kubectl apply -f monitoring/grafana-ingress.yaml
      echo "creating tls-secret certificate"
      kubectl apply -f monitoring/certificates.yaml
      echo "Verifying that the Cert-manager has likely automatically created a certificate object using ingress-shim"
      kubectl describe certificate tls-secret --namespace monitoring
    EOT
    
  }
  
}



































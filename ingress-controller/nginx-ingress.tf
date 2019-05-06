# echo "Create an ingress controller"

resource "null_resource" "ingress_controller" {
  provisioner "local-exec" {
    command=<<EOT
      echo "${var.helm_rs_id}"
      echo "Creating a namespace for testing the ingress resources"
      kubectl create namespace monitoring
      echo "Creating a static public ip address for the nginx ingress controller"
      export AKS_RG=$(az aks show --resource-group ${var.aks_rg_name} --n ${var.aks_cluster_name} --query nodeResourceGroup -o tsv)
      az network public-ip create -g $${AKS_RG} --name ${var.ingress_static_ip_name} --allocation-method static
      export INGRESS_IP=$(az network public-ip show -g $${AKS_RG} -n ${var.ingress_static_ip_name}  --query "{address: ipAddress}" -o tsv)
      echo "Use Helm to deploy an NGINX ingress controller"
      helm install stable/nginx-ingress --namespace monitoring --set controller.replicaCount=2 --set controller.service.loadBalancerIP="$${INGRESS_IP}"
      echo "Get the resource-id of the public ip"
      PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$${INGRESS_IP}')].[id]" -o tsv)
      echo "Update public ip address with grafana and prometheus DNS name"
      az network public-ip update --ids $PUBLICIPID --dns-name ${var.grafana_dns_name}
      echo "Checking if the k8s load Balancer service has been successfully created for Nginx ingress controller"
      kubectl get service -l app=nginx-ingress --namespace monitoring
      helm repo add azure-samples https://azure-samples.github.io/helm-charts/
      helm install azure-samples/aks-helloworld --namespace monitoring
      helm install azure-samples/aks-helloworld --namespace monitoring --set title="AKS Ingress Demo" --set serviceName="ingress-demo"
      #kubectl apply -f ingress-controller/hello-world-ingress.yaml
      echo "done configuring and testing the ingress controller service"
    EOT
  }

}


################################################################################






















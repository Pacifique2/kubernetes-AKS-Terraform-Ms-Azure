# echo "Create an ingress controller"

resource "null_resource" "ingress_controller" {
  provisioner "local-exec" {
    command=<<EOT
      echo "${var.helm_rs_id}"
      echo "Creating a namespace for testing the ingress resources"
      kubectl create namespace monitoring
      sleep 5O
      echo "Use Helm to deploy an NGINX ingress controller"
      helm install stable/nginx-ingress --namespace monitoring --set controller.replicaCount=2
      sleep 40
      echo "Checking if the k8s load Balancer service has been successfully created for Nginx ingress controller"
      kubectl get service -l app=nginx-ingress --namespace monitoring
      helm repo add azure-samples https://azure-samples.github.io/helm-charts/
      helm install azure-samples/aks-helloworld --namespace monitoring
      helm install azure-samples/aks-helloworld --namespace monitoring --set title="AKS Ingress Demo" --set serviceName="ingress-demo"
      kubectl apply -f ingress-controller/hello-world-ingress.yaml
      echo "done configuring and testing the ingress controller service"
    EOT
  }

}


################################################################################






















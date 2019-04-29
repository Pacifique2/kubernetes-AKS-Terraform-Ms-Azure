# echo "Setting up both prometheus and grafana"

resource "null_resource" "prometheus_grafana" {
  provisioner "local-exec" {
    command=<<EOT
      echo "${var.ingress_controller_id}"
      echo "Installing prometheus with helm charts and rbac enabled"
      helm install --name=prometheus stable/prometheus --namespace monitoring --set rbac.create=true
      sleep 1O
      echo "Use Helm to install grafana"
      helm install stable/grafana --set persistence.enabled=true --set persistence.accessModes={ReadWriteOnce} --set persistence.size=8Gi -n grafana --namespace monitoring
      sleep 30
      echo "Export prometheus server pod's name and set up its local dashboard access"
      export POD_NAME_PMTUS=$(kubectl get pods --namespace monitoring -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
      kubectl --namespace monitoring port-forward $POD_NAME_PMTUS 9090
      echo "Export grafana pod's name and set up its local dashboard access"
      export POD_NAME=$(kubectl get pods --namespace monitoring -l "app=grafana,release=grafana" -o jsonpath="{.items[0].metadata.name}")
      kubectl --namespace monitoring port-forward $POD_NAME 3000
      echo "Retrieve the grafana admin user password"
      export GRAFANA_ADMIN_PASS=$(kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)
      echo "done setting up a monitoring solution on aks based on prometheus and grafana"
    EOT
  }
}


################################################################################






































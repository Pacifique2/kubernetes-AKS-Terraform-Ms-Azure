#!/usr/bin

set -e


cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: devoteam-apps
  name: pod-reader
rules:
- apiGroups: [“”] # “” indicates the core API group
  resources: [“pods”,"pods/log"]
  verbs: [“get”, “watch”, “list”]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: devoteam-apps
subjects:
- kind: User
  name: "pacson@ntakipacyoutlook.onmicrosoft.com" # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # must match the name of the Role
  apiGroup: rbac.authorization.k8s.io
EOF

echo "done creating rbac role and assigning a rolebinding to it"

#!/bin/bash

# Привязываем роли к пользователям/группам
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: secure-operator-binding
  namespace: default
subjects:
- kind: User
  name: secure-operator
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: secrets-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: infrastructure-operator-binding
subjects:
- kind: User
  name: infrastructure-operator
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: infrastructure-administrator-binding
subjects:
- kind: User
  name: infrastructure-administrator
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-writer
  apiGroup: rbac.authorization.k8s.io
EOF

echo "Привязки созданы:"
echo "- secure-operator → secrets-reader (RoleBinding)"
echo "- infrastructure-operator → cluster-reader (ClusterRoleBinding)"
echo "- infrastructure-administrator → cluster-writer (ClusterRoleBinding)"
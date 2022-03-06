#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid - Deploy and Access the Kubernetes Dashboard
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tkg-build-variables.sh

if [ ! -f ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ]; then
    echo "File: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} missing ..."
    echo "Exiting ..."
    exit 1
fi

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}

echo "Deploy Kubernetes dashboard, apply the manifest"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml


echo "Waiting for pods to be created."
for POD in `kubectl -n kubernetes-dashboard get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n kubernetes-dashboard wait --for=condition=Ready pod/${POD} --timeout=120s
done

echo "Creating an admin user account with full privileges to modify the cluster. Don't do this in Production!!!"
cat > ${HOME}/scripts/k8s-dashboard-admin.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -n kubernetes-dashboard -f ${HOME}/scripts/k8s-dashboard-admin.yaml

echo "Modify the service type to LoadBalancer."
kubectl -n kubernetes-dashboard get service/kubernetes-dashboard -o yaml > ${HOME}/scripts/k8s-dashboard-service.yaml
sed -i 's/ClusterIP/LoadBalancer/g' ${HOME}/scripts/k8s-dashboard-service.yaml
kubectl apply -n kubernetes-dashboard -f ${HOME}/scripts/k8s-dashboard-service.yaml

echo "Waiting for kubernetes-dashboard pods to be created."
for POD in `kubectl -n kubernetes-dashboard get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n kubernetes-dashboard wait --for=condition=Ready pod/${POD} --timeout=300s
done

echo "Sleeping 20 seconds ..."
sleep 20

ExternalIp=`kubectl -n kubernetes-dashboard get service/kubernetes-dashboard | grep LoadBalancer | awk '{print $4}'`
echo " "
echo "To access Kubernetes Dashboard, go to https://${ExternalIp}"
echo " "
echo "Select the token authentication method and copy your admin token (bellow) into the token field."
echo "------------------------------------------------------------------------------"
kubectl get secret -n kubernetes-dashboard $(kubectl get serviceaccount admin-user -n kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
echo "------------------------------------------------------------------------------"

## To remove the kubernetes dashboard execute the following commands:
## kubectl delete --all  deployments,services,replicasets --namespace=kubernetes-dashboard
## kubectl delete namespace kubernetes-dashboard
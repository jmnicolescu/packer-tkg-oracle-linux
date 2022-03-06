#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid - Deploy Demo App: assembly-webapp
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

#--------------------------------------------------------------------------
# Demo App: assembly-webapp
#--------------------------------------------------------------------------

echo "Demo App: Installing assembly-webapp"
kubectl create namespace assembly
kubectl apply -f ${HOME}/scripts/71-assembly-deployment.yaml

echo "Waiting for assembly-webapp pods to be created."
for POD in `kubectl -n assembly get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n assembly wait --for=condition=Ready pod/${POD} --timeout=300s
done

kubectl get pods,services --namespace=assembly
ExternalIp=`kubectl -n assembly get service/assembly-service | grep LoadBalancer | awk '{print $4}'`
echo " "
echo "To access assembly webapp, go to http://${ExternalIp}:8080"
echo " "

## To remove the assembly webapp execute the following commands
## kubectl delete --all  deployments,services,replicasets --namespace=assembly
## kubectl delete namespace assembly
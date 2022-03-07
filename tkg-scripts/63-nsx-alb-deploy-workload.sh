#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid
# Deploy a Management Cluster to vSphere Infrastructure / Single Control Plane - Development
#
# TCE Documenntation: Deploying a workload cluster to vSphere
# https://tanzucommunityedition.io/docs/latest/workload-clusters/
#
# TKG Documentation: TKG 1.4 Deploy Tanzu Kubernetes Clusters
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-k8s-clusters-index.html
#
# Tanzu CLI Configuration File Variable Reference
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-config-reference.html
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 63-nsx-alb-deploy-workload.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

# Make sure that kubectl is connected to the correct management cluster context.
echo "Setting kubectl context to the management cluster."
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl config current-context

if [ ! -f ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml ]; then
    echo "Expecting Management cluster config in ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml"
    echo "Exiting ..."
    exit 1
fi

echo "Creating workload cluster [ ${WKLD_CLUSTER_NAME} ] configuration file."
cp -f ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml

echo "Updating workload cluster configuration file - {HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml"
sed -i "s/^CLUSTER_NAME.*/CLUSTER_NAME: ${WKLD_CLUSTER_NAME}/" ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml

# Update the number of master nodes -- dev = 1 node, prod = 3 nodes
sed -i "s/^CLUSTER_PLAN.*/CLUSTER_PLAN: prod/" ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml

# Update the number of worker nodes
cat >> ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml <<EOF
WORKER_MACHINE_COUNT: "3"
CONTROL_PLANE_MACHINE_COUNT: "3"
ENABLE_DEFAULT_STORAGE_CLASS: "true"
EOF

echo "Copy cluster configuration file to the default tkg location."
mkdir -p  ${HOME}/.config/tanzu/tkg/clusterconfigs
cp ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml ${HOME}/.config/tanzu/tkg/clusterconfigs/${WKLD_CLUSTER_NAME}-config.yaml

echo "#--------------------------------------------------------------"
echo "Create the workload cluster [ ${WKLD_CLUSTER_NAME} ]"
echo "#--------------------------------------------------------------"
tanzu cluster create --file ${HOME}/scripts/${WKLD_CLUSTER_NAME}-config.yaml -v 6

echo "Sleeping 10 seconds ... wait for the cluster ${WKLD_CLUSTER_NAME} to be available"
sleep 10

tanzu cluster list
tanzu cluster get ${WKLD_CLUSTER_NAME}

## Capture the workload cluster’s kubeconfig
export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin

cp ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ${HOME}/.kube/config

echo "Setting kubectl context to the workload cluster."
kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
kubectl config current-context
kubectl get nodes -A

END_POINT=`cat ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} | grep server | awk '{print $2}'`
echo "  "
echo "End point check for ${END_POINT}"
curl --insecure ${END_POINT}

echo "List all available clusters ..."
tanzu cluster list --include-management-cluster

cat << EOF

#----------------------------------------------------------------------------
# To access the management cluster [ ${WKLD_CLUSTER_NAME} ] use:
#----------------------------------------------------------------------------

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
kubectl get nodes -A

If you need to recapture the management cluster's kubeconfig, execute the following commands:

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin
kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
kubectl get nodes -A

#----------------------------------------------------------------------------

EOF

echo "Done 63-nsx-alb-deploy-workload.sh"
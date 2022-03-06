#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Kubernetes Grid - Install Fluent Bit using TCE Tanzu Packages. 
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Reference:
# https://cormachogan.com/2021/10/05/getting-started-with-carvel-and-tanzu-packages-in-tce/
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tkg-build-variables.sh

if [ ! -f ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ]; then
    echo "File: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} missing ..."
    echo "Exiting ..."
    exit 1
fi

export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}

echo "Installing repository to the default namespace."
echo "Adding TKG package repository..."

# “tanzu-package-repo-global” namespace is now created via the kapp-controller manifest.
# REPO_NAME="tkg-main-latest"
# REPO_URL="projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0"
# REPO_NAMESPACE="tanzu-package-repo-global"

# tanzu package repository add ${REPO_NAME} --url ${REPO_URL} --namespace ${REPO_NAMESPACE} --create-namespace
# tanzu package repository get ${REPO_NAME} -o json | jq -r '.[0].status | select (. != null)'

# echo "Sleeping 60 seconds ... wait for packages to be available"
# sleep 60
tanzu package repository list -A

echo "#--------------------------------------------------------------"
echo "tkg package repository -> Checking available package list ..."
echo "#--------------------------------------------------------------"
tanzu package available list

echo "#--------------------------------------------------------------"
echo "tkg package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

#--------------------------------------------------------------------------
# Demo App: Fluent Bit
#--------------------------------------------------------------------------

DEMO_FLUENT_BIT_PACKAGE="fluent-bit.tanzu.vmware.com"

echo "Demo App #1: Installing fluent-bit -- Fluent Bit is a fast Log Processor and Forwarder"
tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE}
fluentbit_version=$(tanzu package available list ${DEMO_FLUENT_BIT_PACKAGE} -o json | jq -r '.[0].version | select(. !=null)')
tanzu package install fluent-bit --package-name ${DEMO_FLUENT_BIT_PACKAGE} --version "${fluentbit_version}"
tanzu package installed list
kubectl -n tanzu-system-loggin get all

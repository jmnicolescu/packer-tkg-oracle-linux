#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid 
# Deploy a Management Cluster to vSphere Infrastructure / Single Control Plane - Development
#
# TCE Documentation: Deploy a Management Cluster to vSphere 
# https://tanzucommunityedition.io/docs/latest/vsphere-install-mgmt/
#
# TKG Documentation: TKG 1.4 Deploy Management Clusters
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-mgmt-clusters-deploy-management-clusters.html
#
# Tanzu CLI Configuration File Variable Reference
# https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-tanzu-config-reference.html
#
# Tanzu Kubernetes Grid Service is the preferred way to consume Tanzu Kubernetes Grid in vSphere 7.0 environments.
# To deploy a non-integrated Tanzu Kubernetes Grid instance on vSphere 7.0, we set the 'DEPLOY_TKG_ON_VSPHERE7' variable to 'true' 
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 62-nsx-alb-deploy-management.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

if [ ! -f ${HOME}/ova/avi-nsxalb-controller.cert ]; then
    echo "NSX ALB Contrlloer Certificate expected in ${HOME}/ova/avi-nsxalb-controller.cert"
    echo "Go to: Templates > Security > SSL/TLS Certificates, Select controller-certificate, Click Export"
    echo "Exiting ..."
    exit 1
fi

if [ ! -f ${HOME}/.ssh/id_rsa.pub ]; then
    echo "SSH Public Key expected in {HOME}/.ssh/id_rsa.pub"
    echo "Exiting ..."
    exit 1
fi

export NSXALB_AVI_CA_DATA_B64=`cat ${HOME}/ova/avi-nsxalb-controller.cert | base64 -w 0`
export VSPHERE_SSH_KEY=`cat ${HOME}/.ssh/id_rsa.pub`

echo "Pre-req check, increase connection tracking table size."
sudo sysctl -w net.netfilter.nf_conntrack_max=524288

echo "Pre-req check, ensure bootstrap machine has ipv4 and ipv6 forwarding enabled."
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.ip_forward=1

# Example: Create the management cluster via the UI
# tanzu management-cluster create --ui --bind ${MY_IP_ADDRESS}:8080 --browser none

echo "#-----------------------------------------------------------------------------------"
echo "Create management cluster [ ${MGMT_CLUSTER_NAME} ] configuration file using CLUSTER_PLAN = dev"
echo "#-----------------------------------------------------------------------------------"

cat > ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml <<EOF
AVI_CA_DATA_B64: "${NSXALB_AVI_CA_DATA_B64}"
AVI_CLOUD_NAME: "${NSXALB_AVI_CLOUD_NAME}"
AVI_CONTROL_PLANE_HA_PROVIDER: "true"
AVI_CONTROLLER: "${NSXALB_CONTROLLER_IP}"
AVI_DATA_NETWORK: "${NSXALB_AVI_DATA_NETWORK_NAME}"
AVI_DATA_NETWORK_CIDR: "${NSXALB_AVI_DATA_NETWORK_CIDR}"
AVI_ENABLE: "true"
AVI_LABELS: ""
AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_CIDR: "${NSXALB_AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_CIDR}"
AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_NAME: "${NSXALB_AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_NAME}"
AVI_PASSWORD: "$(pass provider_vcenter_password)"
AVI_SERVICE_ENGINE_GROUP: "${NSXALB_AVI_SERVICE_ENGINE_GROUP}"
AVI_USERNAME: "admin"
CLUSTER_CIDR: 100.96.0.0/11
CLUSTER_NAME: ${MGMT_CLUSTER_NAME}
CLUSTER_PLAN: dev
ENABLE_AUDIT_LOGGING: "false"
ENABLE_CEIP_PARTICIPATION: "false"
ENABLE_MHC: "true"
IDENTITY_MANAGEMENT_TYPE: none
INFRASTRUCTURE_PROVIDER: vsphere
LDAP_BIND_DN: ""
LDAP_BIND_PASSWORD: ""
LDAP_GROUP_SEARCH_BASE_DN: ""
LDAP_GROUP_SEARCH_FILTER: ""
LDAP_GROUP_SEARCH_GROUP_ATTRIBUTE: ""
LDAP_GROUP_SEARCH_NAME_ATTRIBUTE: cn
LDAP_GROUP_SEARCH_USER_ATTRIBUTE: DN
LDAP_HOST: ""
LDAP_ROOT_CA_DATA_B64: ""
LDAP_USER_SEARCH_BASE_DN: ""
LDAP_USER_SEARCH_FILTER: ""
LDAP_USER_SEARCH_NAME_ATTRIBUTE: ""
LDAP_USER_SEARCH_USERNAME: userPrincipalName
OIDC_IDENTITY_PROVIDER_CLIENT_ID: ""
OIDC_IDENTITY_PROVIDER_CLIENT_SECRET: ""
OIDC_IDENTITY_PROVIDER_GROUPS_CLAIM: ""
OIDC_IDENTITY_PROVIDER_ISSUER_URL: ""
OIDC_IDENTITY_PROVIDER_NAME: ""
OIDC_IDENTITY_PROVIDER_SCOPES: ""
OIDC_IDENTITY_PROVIDER_USERNAME_CLAIM: ""
OS_ARCH: "amd64"
OS_NAME: ${NODE_OS_NAME}
OS_VERSION: "${NODE_OS_VERSION}"
SERVICE_CIDR: 100.64.0.0/13
TKG_HTTP_PROXY_ENABLED: "false"
VSPHERE_CONTROL_PLANE_DISK_GIB: "40"
VSPHERE_CONTROL_PLANE_ENDPOINT: 
VSPHERE_CONTROL_PLANE_MEM_MIB: "8192"
VSPHERE_CONTROL_PLANE_NUM_CPUS: "2"
VSPHERE_DATACENTER: "/${VSPHERE_DATACENTER}"
VSPHERE_DATASTORE: "/${VSPHERE_DATACENTER}/datastore/${VSPHERE_DATASTORE}"
VSPHERE_FOLDER: "/${VSPHERE_DATACENTER}/vm/${VSPHERE_FOLDER}"
VSPHERE_NETWORK: "/${VSPHERE_DATACENTER}/network/${VSPHERE_NETWORK_SWITCH}/${TANZU_DEPLOY_NETWORK}"
VSPHERE_RESOURCE_POOL: "/${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}/Resources/${VSPHERE_RESOURCE_POOL}"
VSPHERE_SSH_AUTHORIZED_KEY: "${VSPHERE_SSH_KEY}"
VSPHERE_TLS_THUMBPRINT: ${VSPHERE_TLS_THUMBPRINT}
VSPHERE_SERVER: "$(pass provider_vcenter_hostname)"
VSPHERE_USERNAME: "$(pass provider_vcenter_username)"
VSPHERE_PASSWORD: "$(pass provider_vcenter_password)"
VSPHERE_WORKER_DISK_GIB: "40"
VSPHERE_WORKER_MEM_MIB: "8192"
VSPHERE_WORKER_NUM_CPUS: "2"
EOF

echo "Copy cluster configuration file to the default tkg location."
mkdir -p  ~/.config/tanzu/tkg/clusterconfigs
cp ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml ${HOME}/.config/tanzu/tkg/clusterconfigs/${MGMT_CLUSTER_NAME}-config.yaml

echo "Create management cluster [ ${MGMT_CLUSTER_NAME} ]."
tanzu management-cluster create ${MGMT_CLUSTER_NAME}  --file ${HOME}/scripts/${MGMT_CLUSTER_NAME}-config.yaml --verbose 10 --ceip-participation=false --timeout 60m

# Check management cluster details
tanzu management-cluster get

# Troubleshooting notes
# export KUBECONFIG=`ls /home/tkg/.kube-tkg/tmp/config_*`
# kubectl get pods,deployments -A
# 
# Bootstrap  cluster kubeconfig /home/tkg/.kube-tkg/tmp/config_*
# Management cluster kubeconfig /home/tkg/.kube/config

# Capture the management cluster’s kubeconfig 
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin

echo "Setting kubectl context to the management cluster."
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A

END_POINT=`cat ${HOME}/.kube/config-${MGMT_CLUSTER_NAME} | grep server | awk '{print $2}'`
echo "  "
echo "End point check for ${END_POINT}"
curl --insecure ${END_POINT}

echo "List all available clusters ..."
tanzu cluster list --include-management-cluster

cat << EOF

#----------------------------------------------------------------------------
# To access the management cluster [ ${MGMT_CLUSTER_NAME} ] use:
#----------------------------------------------------------------------------

export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
kubectl get nodes -A

If you need to recapture the management cluster's kubeconfig, execute the following commands:

export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A

#----------------------------------------------------------------------------

EOF

echo "Done 62-nsx-alb-deploy-management.sh"
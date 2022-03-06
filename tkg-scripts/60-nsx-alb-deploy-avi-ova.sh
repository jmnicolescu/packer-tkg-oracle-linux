#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition / Tanzu Kubernetes Grid 
# Deploy NSX Advanced Load Balancer
#
# Download VMware NSX Advanced Load Balancer
# https://customerconnect.vmware.com/en/downloads/info/slug/infrastructure_operations_management/vmware_tanzu_kubernetes_grid/1_x
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

############################################################################
##
## REQUIREMENTS - Store vCenter secrets by using the pass insert command:
##
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
#############################################################################

echo "#--------------------------------------------------------------"
echo "# Starting 60-nsx-alb-deploy-avi-ova.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tkg-build-variables.sh

export GOVC_URL="https://$(pass provider_vcenter_hostname)"
export GOVC_USERNAME=$(pass provider_vcenter_username)
export GOVC_PASSWORD=$(pass provider_vcenter_password)
export GOVC_INSECURE=true
export VSPHERE_SSH_KEY=`cat ${HOME}/.ssh/id_rsa.pub`

# Extract the ova-specs from the ova image
# govc import.spec ${NSXALB_OVA_FILE} | jq . > ${NSXALB_OVA_JSON_FILE}
rm -f ${NSXALB_OVA_JSON_FILE}

echo "Updating ova-specs file with the Network info [ $NSXALB_MANAGEMENT_NETWORK ]"
cat > ${NSXALB_OVA_JSON_FILE} << EOF
{
  "DiskProvisioning": "flat",
  "IPAllocationPolicy": "Static - Manual",
  "IPProtocol": "IPv4",
  "PropertyMapping": [
    {
      "Key": "avi.mgmt-ip.CONTROLLER",
      "Value": "${NSXALB_CONTROLLER_IP}"
    },
    {
      "Key": "avi.mgmt-mask.CONTROLLER",
      "Value": "${NSXALB_CONTROLLER_NETMASK}"
    },
    {
      "Key": "avi.default-gw.CONTROLLER",
      "Value": "${NSXALB_CONTROLLER_GATEWAY}"
    },
    {
      "Key": "avi.sysadmin-public-key.CONTROLLER",
      "Value": "${VSPHERE_SSH_KEY}"
    },
    {
      "Key": "avi.nsx-t-node-id.CONTROLLER",
      "Value": ""
    },
    {
      "Key": "avi.nsx-t-ip.CONTROLLER",
      "Value": ""
    },
    {
      "Key": "avi.nsx-t-auth-token.CONTROLLER",
      "Value": ""
    },
    {
      "Key": "avi.nsx-t-thumbprint.CONTROLLER",
      "Value": ""
    },
    {
      "Key": "avi.hostname.CONTROLLER",
      "Value": "${NSXALB_CONTROLLER_HOSTNAME}"
    }
  ],
  "NetworkMapping": [
    {
      "Name": "Management",
      "Network": "${NSXALB_MANAGEMENT_NETWORK}"
    }
  ],
  "MarkAsTemplate": false,
  "PowerOn": false,
  "InjectOvfEnv": false,
  "WaitForIP": false,
  "Name": null
}
EOF

echo "  "
echo "-----------------------------------------------------------------------------------------"
echo "Deploying NSX Advanced Load Balancer."
echo "OVA file:          ${NSXALB_OVA_FILE}"
echo "OVA specs file:    ${NSXALB_OVA_JSON_FILE}"
echo "VM name:           ${NSXALB_VM_NAME}"
echo "VM folder:         ${VSPHERE_FOLDER}"
echo "-----------------------------------------------------------------------------------------"
echo "  "

govc import.ova -ds=${VSPHERE_DATASTORE} -folder=${VSPHERE_FOLDER} -pool=${VSPHERE_RESOURCE_POOL} -name=${NSXALB_VM_NAME} \
   -options="${NSXALB_OVA_JSON_FILE}" ${NSXALB_OVA_FILE}

echo "  "
echo "Resizing AVI NSX ALB - ${NSXALB_VM_NAME}"
govc vm.change -vm ${NSXALB_VM_NAME} -c=4
govc vm.change -vm ${NSXALB_VM_NAME} -m=16384

echo "  "
echo "Power ON VM - ${NSXALB_VM_NAME}"
govc vm.power -on=true ${NSXALB_VM_NAME}

echo "  "
echo "-----------------------------------------------------------------------------------------"
echo "Wait 10 minutes before accessing the Controller using http://${NSXALB_CONTROLLER_IP}"
echo "-----------------------------------------------------------------------------------------"

echo "Done 60-nsx-alb-deploy-avi-ova.sh"


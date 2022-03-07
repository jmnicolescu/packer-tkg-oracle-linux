#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Tanzu Kubernetes Grid - Build Variable Definition
#
# Network Configuration
#     VLAN ID: 130   VLAN NAME: "tanzu-management"    CIDR: 192.168.130.0/24
#     VLAN ID: 131   VLAN NAME: "tanzu-workload"      CIDR: 192.168.131.0/24
#     VLAN ID: 132   VLAN NAME: "tanzu-frontend"      CIDR: 192.168.132.0/24
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# Tanzu Kubernetes Grid  - previous build component versions
# TKG_VERSION="1.4.0"
# K8S_VERSION="1.21.2"
# OVA_FILE="${HOME}/ova/photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova"
#--------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------
# Tanzu Kubernetes Grid  - current build component versions
# TKG_VERSION="1.5.1"
# K8S_VERSION="1.22.5"
# OVA_FILE="${HOME}/ova/photon-3-kube-v1.22.5+vmware.1-tkg.2-790a7a702b7fa129fb96be8699f5baa4.ova"
#--------------------------------------------------------------------------------------

if test -f "${HOME}/scripts/.tkg_index";
then
    export INDEX=`cat ${HOME}/scripts/.tkg_index`
else
    export INDEX=0
fi

# ----------------------------------------------------------------------------------------
# Deployment Option #1 -- Three Network Configuration, Separate Workload, Frontend Networks
# ----------------------------------------------------------------------------------------
# export NETWORK_TANZU_MANAGEMENT="tanzu-management"
# export NETWORK_TANZU_WORKLOAD="tanzu-workload"
# export NETWORK_TANZU_FRONTEND="tanzu-frontend"

# ----------------------------------------------------------------------------------------
# Deployment Option #2 -- Two Network Configuration, One Network for Workload and Frontend
# ----------------------------------------------------------------------------------------
export NETWORK_TANZU_MANAGEMENT="tanzu-management"
export NETWORK_TANZU_WORKLOAD="tanzu-workload"

export TKG_VERSION="1.5.1"
export K8S_VERSION="1.22.5"
export KIND_VERSION="0.11.1"
export OCTANT_VERSION="0.25.0"

export MGMT_CLUSTER_NAME="tkg-management"
export WKLD_CLUSTER_NAME="tkg-workload"
export DEPLOY_TKG_ON_VSPHERE7="true" 

# vCenter Info
export VSPHERE_DATACENTER="west-dc"
export VSPHERE_CLUSTER="west-cluster"
export VSPHERE_DATASTORE="nfsdatastore02"
export VSPHERE_NETWORK_SWITCH="vds-west-02"

# ----------------------------------------------------------------------------------------
# Obtain vSphere Certificate Thumbprints
# ssh root@vCenter_Server_Appliance  'openssl x509 -in /etc/vmware-vpx/ssl/rui.crt -fingerprint -sha1 -noout'
# ----------------------------------------------------------------------------------------
export VSPHERE_TLS_THUMBPRINT="F8:5B:CA:DF:47:97:57:01:05:66:DF:AE:02:DB:DA:BC:27:0C:2F:6E"
export VSPHERE_SSH_KEY=`cat ${HOME}/.ssh/id_rsa.pub`
export VSPHERE_FOLDER="tanzu-kubernetes-grid-${INDEX}"
export VSPHERE_RESOURCE_POOL="tanzu-kubernetes-grid-${INDEX}"

# ----------------------------------------------------------------------------------------
# Deployment Option : Using KUBE-VIP and METALLB.
# Deployment using  : scripts/52-vsphere-deploy-management.sh
#                     scripts/53-vsphere-deploy-workload.sh
# ----------------------------------------------------------------------------------------

# Cluster control plane network and end points
export TANZU_DEPLOY_NETWORK=${NETWORK_TANZU_WORKLOAD}
export MGMT_VSPHERE_CONTROL_PLANE_ENDPOINT="192.168.131.132"
export WKLD_VSPHERE_CONTROL_PLANE_ENDPOINT="192.168.131.133"

# METALLB_VIP_RANGE to be defined on TANZU_DEPLOY_NETWORK
export METALLB_VIP_RANGE="192.168.131.241-192.168.131.250"

# ----------------------------------------------------------------------------------------
# Deployment Option : Using NSX ALB.
# Deployment using  : scripts/62-nsx-alb-deploy-management.sh
#                     scripts/63-nsx-alb-deploy-workload.sh
# ----------------------------------------------------------------------------------------

# AVI NSX ALB - OVA deployment specs
export NSXALB_VM_NAME="avi-nsx-alb"
export NSXALB_OVA_FILE="${HOME}/ova/controller-21.1.2-9124.ova"
export NSXALB_OVA_JSON_FILE="${HOME}/ova/avi-nsxalb-ova-specs.json"
export NSXALB_MANAGEMENT_NETWORK=${NETWORK_TANZU_MANAGEMENT}
export NSXALB_CONTROLLER_HOSTNAME="avi-nsx-alb"
export NSXALB_CONTROLLER_IP="192.168.130.190"
export NSXALB_CONTROLLER_NETMASK="255.255.255.0"
export NSXALB_CONTROLLER_GATEWAY="192.168.130.1"

# ----------------------------------------------------------------------------------------
# Obtain NSX ALB Controller Certificate
# NSXALB_AVI_CA_DATA_B64=`cat ${HOME}/ova/avi-nsxalb-controller.cert | base64 -w 0`
# ----------------------------------------------------------------------------------------
export NSXALB_AVI_CA_DATA_B64="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMxVENDQWIyZ0F3SUJBZ0lVQzF0SEVzSTFZQnZPM2hyVHM5WW9nTmJocEM4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd0dqRVlNQllHQTFVRUF3d1BNVGt5TGpFMk9DNHhNekF1TVRrd01CNFhEVEl5TURJeE5qRXpNVFEwT0ZvWApEVEl6TURJeE5qRXpNVFEwT0Zvd0dqRVlNQllHQTFVRUF3d1BNVGt5TGpFMk9DNHhNekF1TVRrd01JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTFhWDUyUEhZT1FMc2Q1N3ducld2Vmg5WUFFbVoKYW5ScVU3Z256WXNOWWFoaVNIeFlhbzladTdqVXJPQldJRjcrMWVtVmVJWGpQS3liaC9KNENtdm1UTWhFL3hmNgpwWXRiaFB6LzJRcXZ6Mk03SC9EWG5jUEdpcTg5S0RBZVROL2lnUzk3MiszS3dDTnFYLzJtbjRDTlhxWDR0UmtVCjNCdFlydkZLakpqcDVOTTMzSmdsQWdXUnoxL1I2WG1Lc3h1SUQzZnRuK1FYRXlwSmVONjlTWXREb0FpYzZNLzIKVGlRM3ZkNlhURUJpR1g3OWxxVzJLc1F6ZXl6SHd1NHBzWWxORVE0RW82dndudklFYmtoYUdxTHlEL2xsRk1tNApXNDJmWnJ2cWtTZzB6Wmt2TSt2VjQwR1NmV1FEUWZSZmx6NXpNMDk5eURsUnY2RysyWVZnNlo4UVB3SURBUUFCCm94TXdFVEFQQmdOVkhSRUVDREFHaHdUQXFJSytNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUURTWER1amlWWnQKM3UrK0VEdW5KTWZmY2N6UC8yTUFQbCtodEI3VkxnUG1yOWNnZkIxOFlyUk5VZHZJa0lDMTdiTTdXY3RtMk5kYwoyNmp4cE55a1VDQlZsSitEQnRVOFZPVWwwMkh5UmluWERBT0ZQQlVlNndCMTVnU3pHcSs4aXE0NWQ5T3BTVFBiClI1SVVybXhHMjZ2bVlGRUhqaCtZdnpZTmozK0EzYTgxQUE1anAwVnFKc3hxQWFwTWxWTW00VXdTYjhVSmRvd0MKcUEwRFlXODQ4dUYxU0xPWmFpS3hJbVU3N2EzeGREV0Z5WUlucnFlNU1MNGtKY0c2NVJXVnR5RmI1V3crRUtpZAppc2x5VS9RZTV0V29FaVJQSTBqSXlqSk9jeUlPSWwyVzlwdjAvMG96anlHZG9lUFVHZEt6U2lDcjg3MFZ2YUZOClVtVTZIMkQ1NGtvLwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
export NSXALB_AVI_CLOUD_NAME="Default-Cloud"
export NSXALB_AVI_SERVICE_ENGINE_GROUP="Default-Group"
# VIP networks for Management VIPs (control plane endpoints) 
export NSXALB_AVI_DATA_NETWORK_NAME=${NETWORK_TANZU_WORKLOAD}
export NSXALB_AVI_DATA_NETWORK_CIDR="192.168.131.0/24"
# VIP networks for Workload VIPs (workload load balancer services). 
export NSXALB_AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_NAME=${NETWORK_TANZU_WORKLOAD}
export NSXALB_AVI_MANAGEMENT_CLUSTER_VIP_NETWORK_CIDR="192.168.131.0/24"

# K8s node VM settings for Photon v3 Kubernetes v1.22.5 OVA
export OVA_VM_NAME="photon-3-kube-v1.22.5+vmware.1-tkg.2-790a7a702b7fa129fb96be8699f5baa4"
export OVA_FILE="${HOME}/ova/photon-3-kube-v1.22.5+vmware.1-tkg.2-790a7a702b7fa129fb96be8699f5baa4.ova"
export OVA_JSON_FILE="${HOME}/ova/kubernetes-node-ova-specs.json"
export NODE_OS_NAME="photon"
export NODE_OS_VERSION="3"

# Kubernetes node OS VM settings for Ubuntu OS
# export OVA_VM_NAME="ubuntu-2004-kube-v1.21.2+vmware.1-tkg.1-7832907791984498322"
# export OVA_FILE="${HOME}/ova/ubuntu-2004-kube-v1.21.2+vmware.1-tkg.1-7832907791984498322.ova"
# export OVA_JSON_FILE="${HOME}/ova/kubernetes-node-ova-specs.json"
# export NODE_OS_NAME="ubuntu"
# export NODE_OS_VERSION="20.04"

# Obtain current IP for Oracle Linux / Ubuntu 
export MY_IP_ADDRESS=`ifconfig ens192 | grep 'inet ' | awk '{print $2}'`
export MY_STATIC_IP="192.168.111.129"
export MY_DOMAIN_NAME="flexlab.local"

# Obtain current IP for Photon OS
# export MY_IP_ADDRESS=`ifconfig eth0 | grep '192.168.' | awk '{print $2}' | cut -d ":" -f2`
# export MY_DOMAIN_NAME="flexlab.local"
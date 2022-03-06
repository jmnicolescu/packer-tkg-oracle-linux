
## NSX-ALB (AVI) Controller Setup


#### Download the software

Download VMware NSX Advanced Load Balancer from the following URL:

https://customerconnect.vmware.com/en/downloads/info/slug/infrastructure_operations_management/vmware_tanzu_kubernetes_grid/1_x


#### Documentation

1. VMware NSX Advanced Load Balancer Documentation
https://docs.vmware.com/en/VMware-NSX-Advanced-Load-Balancer/index.html

2. Avi Documentation
https://avinetworks.com/docs/


#### Network Topology

NSX ALB topology - Two Network Configuratio - Separate Management Network, Combined Workload Network and Frontend/VIP Network.

```bash
VLAN Configuration
      VLAN ID: 130   VLAN NAME: "tanzu-management"    CIDR: 192.168.130.0/24
      VLAN ID: 131   VLAN NAME: "tanzu-workload"      CIDR: 192.168.131.0/24

NSX ALB Management Network:
      VLAN: tanzu-management
      IP Subnet: 192.168.130.0/24
      Controller IP: 192.168.130.190
      DHCP Range: 192.168.130.50 - 192.168.130.100
      Static IP Address Pool (for SE): 192.168.130.191-192.168.130.199
      [ This range is used to configure the Management Network NIC in the AVI Service Engines.]

NSX ALB Workload/VIP Network:
      VLAN: tanzu-workload
      IP Subnet: 192.168.131.0/24
      DHCP Range (for TKG Nodes): 192.168.131.50 - 192.168.131.100
      Staic IP Address Pool (for VIPs): 192.168.131.151-192.168.131.199 
      [ This range is used by the various Kubernetes control planes and Kubernetes applications that require a Load Balancer Service. ]

```

#### Deploy NSX Advanced Load Balancer OVA

1. Set NSX ALB specs in the configuration 00-tce-build-variables.sh 
2. Run 60-nsx-alb-deploy-avi-ova.sh script to deploy NSX Advanced Load Balancer


#### Controller Configuration

Power on the Controller VM. Wait 10 minutes and access the Controller IP in the Browser. 
For the admin username choose a password. Email is optional.

#### 1. Initial Controller Setup [ Wecome Screen ]

```
  Welocme admin -> System Settings
    Passphrase:
    Confirm Passphrase:
    DNS Resolver(s):   192.168.130.1
    DNS Search Domain:  flexlab.local
    Click [Next]

  Welocme admin -> Email/SMTP
    None
    Click [Next]

  Welcome admin -> Multi-Tenant
    Leave all the defaults  

  Check the [Setup Cloud After] checkbox at the bottom-right of the screen.
  Click [Save]
```

#### 2. Orchestrator setup [ Infrastructure > Clouds ]

```
  Select Cloud Tab
    Name: Default-Cloud
    Select Cloud Infrastructure Type
    Orchestrator: VMware vCenter/vSphere ESX 
    Click [Next]

  Infrastructure Tab
    Enter vCenter / vSphere Login information
    Username:
    Password:
    vCenter Address:
    Access Permission: Write
    Click [Next]

  Datacenter tab
    Select Datacenter:  west-dc
    Click [Next]
  
  Network
    Select Management Network
      Management Network: tanzu-management
    Service Engine
      Template Service Engine Group: Default-Group
    IP Address Management for Management Network
      IP Subnet: 192.168.130.0/24
      Default Gateway: 192.168.130.1
      [ This range is used to configure the Management Network NIC in the AVI Service Engines.]
      Add Static IP Address Pool: 192.168.130.191-192.168.130.199 
  
  Click [Save]
```

#### 3. Set Scope for Service Engines to Specific vSphere Clusters

```
  Go to: Infrastructure > Cloud Resources (Left) -> Service Engine Group. 
  Select from Default-Cloud -> Default-Group. Clieck the pencil [Edit]

  Choose Advanced Tab
  In the Host & Data Store Scope section
    Select Cluster, Select Include: west-cluster

  Click [Save]
```

#### 4. Upgrade Controller to latest patch 

```
  Go to: Administration > Controller > Software. 
  Click on Upload from Computer and select the avi-patch pkg file.
```

#### 5.  Switch Licensing Tier to Essentials License (VMware NSX ALB essentials for Tanzu)

```
  Go to: Administration > Settings > Licensing. 
  Click on the crank wheel next to the Licensing title. Select Essentials License. 
  
  Click [Save]
  Click [Yes,Continue]  
```

#### 6. Create a Default Gateway route to ensure traffic can flow from SEs to pods

```
  Create a Default Gateway route to ensure traffic can flow from SEs to pods and back to the clients.
  Go to: Infrastructure -> Cloud Resources -> Routing -> Default-CLoud
  In the Static Route Tab
    Click -> [Create] to create a Static Route
    Gateway Subnet: 0.0.0.0/0
    Next Hop (The Gateway of the VIP Network): 192.168.131.1

  Click [Save]
```

#### 7. Configure IPAM Profile

```
  Go to: Templates > Profiles > IPAM/DNS Profiles. 
  Click [Create] to Create IPAM Profile:
    Name: tkg-ipam
    Type: Avi Vantage IPAM
  Click Add Usable Network
    Cloud for Usable Network: Default-Cloud
    Usable Network: tanzu-workload

  Click [Save]
```

#### 8. Add IPAM Profile to Cloud

```
   Go to: Infrastructure > Clouds
   Edit the Default-Cloud
    In Infrastructure Tabgo to * IPAM/DNS * section
    Ipam Profile: tkg-ipam

   Click [Save]
```

#### 9. Create VIP pool

```
  Go to: Infrastructure > Cloud Resources -> Networks
  Edit the network used in the IPAM Profile configuration [tanzu-workload]
  Edit Network Settings: tanzu-workload
  Click [Add Subnet] to Add/Modify Static IP Subnet
    IP Subnet: 192.168.131.0/24
    Add Static IP Address Pool
       Static IP Address Pool: 192.168.131.151-192.168.131.199
  Click [Save]
  Click [Save]
  
  You should see a simillar configuration:
  NAME               DISCOVERED SUBNET   CONFIGURED SUBNET           STATIC IP POOLS
  tanzu-management   192.168.130.0/24    192.168.130.0/24 [9/9]      1
        IP Subnet (Configured) 192.168.130.0/24 [9/9]
        Static IP Pools (Type)  192.168.130.191 - 192.168.130.199 (SE, VIP)
  
  NAME               DISCOVERED SUBNET   CONFIGURED SUBNET           STATIC IP POOLS
  tanzu-workload     None                192.168.131.0/24 [49/49]    1
        IP Subnet (Configured) 192.168.131.0/24 [49/49]
        Static IP Pools (Type) 192.168.131.151 - 192.168.131.199 (SE, VIP) 

```

#### 10. Create Custom Certificate for Controller

```
  Go to: Templates > Security > SSL/TLS Certificates
  Click [Create] to create new a Controller Certificate
    General - Name: controller-certificate
    Certificate - Common Name: 192.168.130.190
    Certificate - Subject Alternate Name (SAN) - Add Name: 192.168.130.190
  Click [Save]

  Go to: Administration > Settings > Access Settings
  Edit System Access Settings
    In the SSL/TLS Certificate - delete all certificates 
          ( Delete System-Default-Portal-Cert )
          ( Delete System-Default-Portal-Cert-EC256 )
    In the SSL/TLS Certificate - add controller-certificate

    Click [Save]

  Restart the browser and accept new controller certificate.

  Go to: Templates > Security > SSL/TLS Certificates
    Select controller-certificate -> clieck Export on the far right
    Copy the Key and the Certificate below:

    KEY: 
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDVpfnY8dg5Aux3
nvCeta9WH1gASZlqdGpTuCfNiw1hqGJIfFhqj1m7uNSs4FYgXv7V6ZV4heM8rJuH
8ngKa+ZMyET/F/qli1uE/P/ZCq/PYzsf8Nedw8aKrz0oMB5M3+KBL3vb7crAI2pf
/aafgI1epfi1GRTcG1iu8UqMmOnk0zfcmCUCBZHPX9HpeYqzG4gPd+2f5BcTKkl4
3r1Ji0OgCJzoz/ZOJDe93pdMQGIZfv2WpbYqxDN7LMfC7imxiU0RDgSjq/Ce8gRu
SFoaovIP+WUUybhbjZ9mu+qRKDTNmS8z69XjQZJ9ZANB9F+XPnMzT33IOVG/ob7Z
hWDpnxA/AgMBAAECggEAPS+wkzoH86PrtwJ05O8hjOejG0n4vu0iOmHGPG5zYaGI
rDu4UqRFTabMecoxwEmUcAzaes7VWl4QmOmPCWUHarv8TpY+eUSk7DxMxYry+NDx
cN9X0N3tsXAocqb9NoTz6I2BymWaqFY8M8t/+bQmSJH93VeWisbmKgv+jq+IZLi2
8eAJqx4acGFMTUcr5y0jVFWFI1YO/ertl5rBk2ksNoSCrmIHmj/x4DGHT1LQxRma
Zn2USZIsjQ94rkNyAdCzK7MjdzjIBOS2SHXuAcdoMgmBqbuFy3+oHDeN+e4zfjSC
aO6EYQTwA9awCAvq4lMrKcZfV4+7Lav2jASnt+lPeQKBgQD0uubY6Taq2iLh95RR
81+bmuMsHq4FCIKZCxxHMvZ9QC1xtSaeBRCY1LwHIn3BzNDPghcJQAtk8Sq3vROm
EcJ7+FGW8oCM+Fz4ejCLo1gXWahDUK11DOPZXEAfKUQXQ2WH/VuloSuIanbsY87p
h2IysNUOS7EvR23zCF36G3Wu2wKBgQDffKebFMmktEpO763pNlQ+Kcw1K3T4r6PB
CM8PzaB4Fn4y+k+xSwiEN12hBgli/bdWxAQrU2mZuUTG57HkWhwozo9m9n7qEpHk
wE0FgWFHLmA/oiHAoHeA8eVnFKIRLUoU797iXoUo9PNWhuihQUaNO5KhYXTTG/9O
7xOEzfTnbQKBgQDQ89OuWFEIx38JGG5XGkkDfteAECHcwktfiJD4aZbzkhw6/cSf
HwvwsZJpNRXSpqGSyywIBdq0sQUcJB/mpzs6xeZDz4Ha2yPmM83HLAxGw5JbB0NS
sVLJf25wLLeqdSz3U2cwn8+fhedMJlvAIIvDZCBFOHNsPrytyPMUXOW6CQKBgQCR
DE+fyHsjCdycpNSj4x4EBo7CB4VwjlZix7vUDupSZo7buTgV4pQRc/mxs8BN3kuq
5aerEwUbv3ITAnejtJRIK+BIvD0c4JaN9/1FUHZ5g3D2e90aL0vAhb8VCwAw08sc
EZ8AHsagEXMJup+rYTlQGtUNJrpy9d3bNjHd5OpJdQKBgHVdeCf5zw5yE1pFaf28
tEVZfmGSbW8tfBzExp7HW2pxBp8bV/JNf5qSELILGpoF4xhDhoP3OQcPs5GuCYs8
wDfq/uBrs4/HAo1TxUruh1oRsGabeDetiuc0xBrH6QakTN1dhnbJuHk2orFSV2Ww
faPQEyMGIzCaQzzdLE8yKA9Z
-----END PRIVATE KEY-----


   CERTIFICATE:
-----BEGIN CERTIFICATE-----
MIIC1TCCAb2gAwIBAgIUC1tHEsI1YBvO3hrTs9YogNbhpC8wDQYJKoZIhvcNAQEL
BQAwGjEYMBYGA1UEAwwPMTkyLjE2OC4xMzAuMTkwMB4XDTIyMDIxNjEzMTQ0OFoX
DTIzMDIxNjEzMTQ0OFowGjEYMBYGA1UEAwwPMTkyLjE2OC4xMzAuMTkwMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1aX52PHYOQLsd57wnrWvVh9YAEmZ
anRqU7gnzYsNYahiSHxYao9Zu7jUrOBWIF7+1emVeIXjPKybh/J4CmvmTMhE/xf6
pYtbhPz/2Qqvz2M7H/DXncPGiq89KDAeTN/igS972+3KwCNqX/2mn4CNXqX4tRkU
3BtYrvFKjJjp5NM33JglAgWRz1/R6XmKsxuID3ftn+QXEypJeN69SYtDoAic6M/2
TiQ3vd6XTEBiGX79lqW2KsQzeyzHwu4psYlNEQ4Eo6vwnvIEbkhaGqLyD/llFMm4
W42fZrvqkSg0zZkvM+vV40GSfWQDQfRflz5zM099yDlRv6G+2YVg6Z8QPwIDAQAB
oxMwETAPBgNVHREECDAGhwTAqIK+MA0GCSqGSIb3DQEBCwUAA4IBAQDSXDujiVZt
3u++EDunJMffcczP/2MAPl+htB7VLgPmr9cgfB18YrRNUdvIkIC17bM7Wctm2Ndc
26jxpNykUCBVlJ+DBtU8VOUl02HyRinXDAOFPBUe6wB15gSzGq+8iq45d9OpSTPb
R5IUrmxG26vmYFEHjh+YvzYNj3+A3a81AA5jp0VqJsxqAapMlVMm4UwSb8UJdowC
qA0DYW848uF1SLOZaiKxImU77a3xdDWFyYInrqe5ML4kJcG65RWVtyFb5Ww+EKid
islyU/Qe5tWoEiRPI0jIyjJOcyIOIl2W9pv0/0ozjyGdoePUGdKzSiCr870VvaFN
UmU6H2D54ko/
-----END CERTIFICATE-----

```

#### 11. Update NSX ALB controller certificate in 00-tkg-build-variables.sh 

```

Create ${HOME}/ova/avi-nsxalb-controller.cert file

## Base64 encode the certificate 
cat << EOF > ${HOME}/ova/avi-nsxalb-controller.cert
-----BEGIN CERTIFICATE-----
MIIC1TCCAb2gAwIBAgIUC1tHEsI1YBvO3hrTs9YogNbhpC8wDQYJKoZIhvcNAQEL
BQAwGjEYMBYGA1UEAwwPMTkyLjE2OC4xMzAuMTkwMB4XDTIyMDIxNjEzMTQ0OFoX
DTIzMDIxNjEzMTQ0OFowGjEYMBYGA1UEAwwPMTkyLjE2OC4xMzAuMTkwMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1aX52PHYOQLsd57wnrWvVh9YAEmZ
anRqU7gnzYsNYahiSHxYao9Zu7jUrOBWIF7+1emVeIXjPKybh/J4CmvmTMhE/xf6
pYtbhPz/2Qqvz2M7H/DXncPGiq89KDAeTN/igS972+3KwCNqX/2mn4CNXqX4tRkU
3BtYrvFKjJjp5NM33JglAgWRz1/R6XmKsxuID3ftn+QXEypJeN69SYtDoAic6M/2
TiQ3vd6XTEBiGX79lqW2KsQzeyzHwu4psYlNEQ4Eo6vwnvIEbkhaGqLyD/llFMm4
W42fZrvqkSg0zZkvM+vV40GSfWQDQfRflz5zM099yDlRv6G+2YVg6Z8QPwIDAQAB
oxMwETAPBgNVHREECDAGhwTAqIK+MA0GCSqGSIb3DQEBCwUAA4IBAQDSXDujiVZt
3u++EDunJMffcczP/2MAPl+htB7VLgPmr9cgfB18YrRNUdvIkIC17bM7Wctm2Ndc
26jxpNykUCBVlJ+DBtU8VOUl02HyRinXDAOFPBUe6wB15gSzGq+8iq45d9OpSTPb
R5IUrmxG26vmYFEHjh+YvzYNj3+A3a81AA5jp0VqJsxqAapMlVMm4UwSb8UJdowC
qA0DYW848uF1SLOZaiKxImU77a3xdDWFyYInrqe5ML4kJcG65RWVtyFb5Ww+EKid
islyU/Qe5tWoEiRPI0jIyjJOcyIOIl2W9pv0/0ozjyGdoePUGdKzSiCr870VvaFN
UmU6H2D54ko/
-----END CERTIFICATE-----
EOF

## Update NSXALB_AVI_CA_DATA_B64 in 00-tkg-build-variables.sh with the certificate string

NSXALB_AVI_CA_DATA_B64=`cat ${HOME}/ova/avi-nsxalb-controller.cert | base64 -w 0`

NSXALB_AVI_CA_DATA_B64="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMxVENDQWIyZ0F3SUJBZ0lVQzF0SEVzSTFZQnZPM2hyVHM5WW9nTmJocEM4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd0dqRVlNQllHQTFVRUF3d1BNVGt5TGpFMk9DNHhNekF1TVRrd01CNFhEVEl5TURJeE5qRXpNVFEwT0ZvWApEVEl6TURJeE5qRXpNVFEwT0Zvd0dqRVlNQllHQTFVRUF3d1BNVGt5TGpFMk9DNHhNekF1TVRrd01JSUJJakFOCkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQTFhWDUyUEhZT1FMc2Q1N3ducld2Vmg5WUFFbVoKYW5ScVU3Z256WXNOWWFoaVNIeFlhbzladTdqVXJPQldJRjcrMWVtVmVJWGpQS3liaC9KNENtdm1UTWhFL3hmNgpwWXRiaFB6LzJRcXZ6Mk03SC9EWG5jUEdpcTg5S0RBZVROL2lnUzk3MiszS3dDTnFYLzJtbjRDTlhxWDR0UmtVCjNCdFlydkZLakpqcDVOTTMzSmdsQWdXUnoxL1I2WG1Lc3h1SUQzZnRuK1FYRXlwSmVONjlTWXREb0FpYzZNLzIKVGlRM3ZkNlhURUJpR1g3OWxxVzJLc1F6ZXl6SHd1NHBzWWxORVE0RW82dndudklFYmtoYUdxTHlEL2xsRk1tNApXNDJmWnJ2cWtTZzB6Wmt2TSt2VjQwR1NmV1FEUWZSZmx6NXpNMDk5eURsUnY2RysyWVZnNlo4UVB3SURBUUFCCm94TXdFVEFQQmdOVkhSRUVDREFHaHdUQXFJSytNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUURTWER1amlWWnQKM3UrK0VEdW5KTWZmY2N6UC8yTUFQbCtodEI3VkxnUG1yOWNnZkIxOFlyUk5VZHZJa0lDMTdiTTdXY3RtMk5kYwoyNmp4cE55a1VDQlZsSitEQnRVOFZPVWwwMkh5UmluWERBT0ZQQlVlNndCMTVnU3pHcSs4aXE0NWQ5T3BTVFBiClI1SVVybXhHMjZ2bVlGRUhqaCtZdnpZTmozK0EzYTgxQUE1anAwVnFKc3hxQWFwTWxWTW00VXdTYjhVSmRvd0MKcUEwRFlXODQ4dUYxU0xPWmFpS3hJbVU3N2EzeGREV0Z5WUlucnFlNU1MNGtKY0c2NVJXVnR5RmI1V3crRUtpZAppc2x5VS9RZTV0V29FaVJQSTBqSXlqSk9jeUlPSWwyVzlwdjAvMG96anlHZG9lUFVHZEt6U2lDcjg3MFZ2YUZOClVtVTZIMkQ1NGtvLwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="

```
#### 12. Done
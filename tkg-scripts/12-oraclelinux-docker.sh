#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Oracle Linux R7 - Install Docker, Docker Compose & JQ [ 12-oraclelinux-docker.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 12-oraclelinux-docker.sh"
echo "#--------------------------------------------------------------"

## Install prerequisites.
yum -y install yum-utils device-mapper-persistent-data lvm2

## Add docker repository.
yum-config-manager --enable ol7_optional_latest ol7_addons

## Install docker.
yum -y install docker-engine

# Install jq(JSON processor)
yum -y install jq

## Setup daemon.
mkdir -p /etc/docker
mkdir -p /etc/systemd/system/docker.service.d

# https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF

## Docker required following service ports to function.
## firewall-cmd --permanent --add-port={2376,2377,7946}/tcp
## firewall-cmd --permanent --add-port={7946,4789}/udp
## firewall-cmd --reload

systemctl start docker
systemctl enable docker
systemctl status docker
docker --version
sudo chmod 666 /var/run/docker.sock

echo "Instaling docker-compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose
docker-compose --version

echo "Done 12-oraclelinux-docker.sh"

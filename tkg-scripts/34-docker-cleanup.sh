#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Docker Cleanup [34-docker-cleanup.sh]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#--------------------------------------------------------------------------

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

# Docker Cleanup - Stop all existing containers
docker kill $(docker ps -q)

# Docker Cleanup - Remove containers
docker rm $(docker ps -a -f status=exited -f status=created -q)

# Docker Cleanup - Prune all existing volumes
docker volume prune --force
docker network prune --force
docker builder prune --all --force

# Docker Cleanup -- Removing:
#  - all stopped containers
#  - all networks not used by at least one container
#  - all volumes not used by at least one container
#  - all images without at least one container associated to them
#  - all build cache
# docker system prune -a --volumes --force

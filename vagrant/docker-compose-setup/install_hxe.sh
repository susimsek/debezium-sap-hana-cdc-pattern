#!/bin/bash

HXE_IMAGE_TAG=2.00.054.00.20210603.1
HXE_MASTER_PASSWORD=HXEHana1
HOME_PATH=/home/vagrant

# Functions #########################################################################

configure_docker_host(){
sudo cat << EOF >> /etc/sysctl.conf
fs.file-max=20000000
fs.aio-max-nr=262144
vm.memory_failure_early_kill=1
vm.max_map_count=135217728
net.ipv4.ip_local_port_range=40000 60999
EOF
sudo sysctl -p
}

prepare_hana_express(){
sudo mkdir $HOME_PATH/hana_express
sudo chown $SUDO_USER -R $HOME_PATH/hana_express
}

create_docker_ignore(){
echo "Create Docker Ignore"
echo "
# Exclude "build-time" ignore files.
.dockerignore
.gcloudignore

# Exclude git history and configuration.
.git
.gitignore
README.md

# Exclude docker compose files.
docker-compose.yaml
docker-compose.*.yml
.env
"> $HOME_PATH/hana_express/.dockerignore
}

create_docker_compose_file(){
echo "Create Docker Compose File"
echo "
version: '3.8'
services:
  hxe:
    image: store/saplabs/hanaexpress:${HXE_IMAGE_TAG}
    hostname: hxe
    container_name: hxe
    restart: unless-stopped
    networks:
      - hananet
    ulimits:
      nofile: 1048576
    sysctls:
      - kernel.shmmax=1073741824
      - net.ipv4.ip_local_port_range=40000 60999
      - kernel.shmmni=4096
      - kernel.shmall=8388608
    command:
        - --agree-to-sap-license
        - --dont-check-system
        - --dont-check-mount-points
        - --master-password
        - ${HXE_MASTER_PASSWORD}
    environment:
      - HXE_MASTER_PASSWORD=${HXE_MASTER_PASSWORD}
    volumes:
      - hxe-data:/hana/mounts
    ports:
      - 39013:39013
      - 39017:39017
      - 39041-39045:39041-39045
      - 1128-1129:1128-1129
      - 59013-59014:59013-59014
networks:
  hananet:
    driver: bridge
    name: hananet
volumes:
  hxe-data:
    driver: local
    name: hxe-data
"> $HOME_PATH/hana_express/docker-compose.yaml
}

login_docker(){
docker login
}


install_hana_express(){
 docker-compose -f $HOME_PATH/hana_express/docker-compose.yaml up -d
}


# Let's go ###################################################################################
configure_docker_host
prepare_hana_express
create_docker_ignore
create_docker_compose_file
login_docker
install_hana_express
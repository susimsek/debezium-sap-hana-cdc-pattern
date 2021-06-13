#!/bin/bash

# Variables ########################################
DOCKER_COMPOSE_VERSION=1.27.4

# Functions ########################################

install_docker-compose(){
  sudo curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose
}

# Let's Go!! ########################################
install_docker-compose

echo "======= Done. PLEASE LOG OUT & LOG Back In ===="
echo "Then validate by executing    'docker-compose version'"
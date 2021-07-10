#!/bin/bash

JENKINS_ENABLED=true
SONARQUBE_ENABLED=true

# DO NOT Execute this script with sudo
if [ $SUDO_USER ]; then
    echo "Please DO NOT execute with sudo !!!    ./install-prereqs.sh"
    echo "Aborting!!!"
    exit 0
fi
sudo ./install_docker.sh
sudo ./install_docker_compose.sh
sudo ./install_golang.sh
if [ "$JENKINS_ENABLED" == true ]
then
echo
echo "## Jenkins"
./install_jenkins.sh
fi
if [ "$SONARQUBE_ENABLED" == true ]
then
echo
echo "## Sonarqube"
sudo ./install_sonarqube.sh
fi

echo "====== Please Logout & Logback in ======"
#!/bin/bash


# DO NOT Execute this script with sudo
if [ $SUDO_USER ]; then
    echo "Please DO NOT execute with sudo !!!    ./install-prereqs.sh"
    echo "Aborting!!!"
    exit 0
fi
sudo ./install_docker.sh
sudo ./install_docker_compose.sh

echo "====== Please Logout & Logback in ======"
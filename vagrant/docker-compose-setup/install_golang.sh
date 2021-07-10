#!/bin/bash

# Variables ########################################
GO_VERSION=1.16.3

# Functions ########################################

install_golang() {
  wget -c https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
}

set_golang_env() {
sudo mkdir -p /vagrant/go

sudo chown -R vagrant /vagrant/go
# If GOPATH already set then DO Not set it again
if [ -z $GOPATH ]
then
    echo "export GOROOT=/usr/local/go" >> /home/vagrant/.profile
    echo "export GOPATH=/vagrant/go" >> /home/vagrant/.profile
    echo "export PATH=$PATH:/usr/local/go/bin" >> /home/vagrant/.profile
    echo "export GOROOT=/usr/local/go" >> /home/vagrant/.bashrc
    echo "export GOPATH=/vagrant/go" >> /home/vagrant/.bashrc
    echo "export PATH=$PATH:/usr/local/go/bin" >> /home/vagrant/.bashrc
else
    echo "======== No Change made to .profile, .bashrc  ====="
fi
}

# Let's Go!! ########################################
install_golang
set_golang_env

echo "======= Done. PLEASE LOG OUT & LOG Back In ===="
echo "Then validate by executing    'go version'"




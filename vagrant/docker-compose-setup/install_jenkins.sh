#!/bin/bash

ADMIN_USER=admin
ADMIN_PASSWORD=root
URL_PREFIX=/jenkins
JENKINS_PORT=8080
JENKINS_IMAGE_TAG=2.277.3-jdk11

# Functions #########################################################################

prepare_jenkins(){
sudo mkdir $HOME/jenkins
sudo chown ${USER} -R $HOME/jenkins
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
"> $HOME/jenkins/.dockerignore
}

create_dockerfile(){
echo "Create Dockerfile"
echo "
# Dockerfile
FROM jenkins/jenkins:${JENKINS_IMAGE_TAG}

# Jenkins plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

VOLUME /var/jenkins_home
"> $HOME/jenkins/Dockerfile
}


create_docker_compose_file(){
echo "Create Docker Compose File"
echo "
version: '3.8'
services:
  jenkins:
    build:
      context: .
    container_name: jenkins
    restart: unless-stopped
    privileged: true
    user: root
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
      - JENKINS_OPTS=--prefix=${URL_PREFIX}
      - JENKINS_USER=${ADMIN_USER}
      - JENKINS_PASS=${ADMIN_PASSWORD}
    volumes:
      - jenkins_data:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
      - /usr/bin/docker-compose:/usr/bin/docker-compose
    ports:
      - ${JENKINS_PORT}:8080
      - 50000:50000
volumes:
  jenkins_data:
    driver: local
    name: jenkins_data
"> $HOME/jenkins/docker-compose.yaml
}

create_admin_user(){
echo "Create Admin User"
echo "
import jenkins.model.*
import hudson.security.*

def env = System.getenv()

def jenkins = Jenkins.getInstance()
jenkins.setSecurityRealm(new HudsonPrivateSecurityRealm(false))
jenkins.setAuthorizationStrategy(new GlobalMatrixAuthorizationStrategy())

def user = jenkins.getSecurityRealm().createAccount(env.JENKINS_USER, env.JENKINS_PASS)
user.save()

jenkins.getAuthorizationStrategy().add(Jenkins.ADMINISTER, env.JENKINS_USER)
jenkins.save()
"> $HOME/jenkins/default-user.groovy
}

set_num_executors(){
echo "Set Num Executors"
echo "
import jenkins.model.*
Jenkins.instance.setNumExecutors(5)
"> $HOME/jenkins/executors.groovy
}

install_plugins(){
echo "Install Plugins"
echo "
kubernetes:1.29.4
workflow-job:2.40
workflow-aggregator:2.6
credentials-binding:1.24
git:4.7.1
command-launcher:1.5
github-branch-source:2.10.2
pipeline-utility-steps:2.7.1
configuration-as-code:1.49
blueocean:1.24.6
kubernetes-cd:2.3.1
docker-workflow:1.26
matrix-auth:2.6.6
sonar:2.13.1
"> $HOME/jenkins/plugins.txt
}

install_jenkins(){
 docker-compose -f $HOME/jenkins/docker-compose.yaml up -d
}


# Let's go ###################################################################################
prepare_jenkins
create_docker_ignore
create_dockerfile
create_docker_compose_file
create_admin_user
set_num_executors
install_plugins
install_jenkins
#!/bin/bash

ADMIN_USER=admin
ADMIN_PASSWORD=root
URL_PREFIX=/sonarqube
SONARQUBE_PORT=9000
SONARQUBE_IMAGE_TAG=8.9-community
POSTGRESQL_USER=sonar
POSTGRESQL_PASSWORD=sonar
HOME_PATH=/home/vagrant

# Functions #########################################################################

configure_docker_host(){
sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 4096
}

prepare_sonarqube(){
sudo mkdir $HOME_PATH/sonarqube
sudo chown $SUDO_USER -R $HOME_PATH/sonarqube
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
"> $HOME_PATH/sonarqube/.dockerignore
}

create_docker_compose_file(){
echo "Create Docker Compose File"
echo "
version: '3.8'
services:
  sonarqube:
    image: sonarqube:${SONARQUBE_IMAGE_TAG}
    container_name: sonarqube
    restart: unless-stopped
    depends_on:
     - db
    networks:
      - sonarnet
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONAR_JDBC_USERNAME=${POSTGRESQL_USER}
      - SONAR_JDBC_PASSWORD=${POSTGRESQL_PASSWORD}
      - sonar.forceAuthentication=true
      - sonar.web.context=${URL_PREFIX}
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins
    ports:
      - ${SONARQUBE_PORT}:9000

  db:
    image: postgres:13
    container_name: sonarqube_db
    restart: unless-stopped
    networks:
      - sonarnet
    environment:
      - POSTGRES_USER=${POSTGRESQL_USER}
      - POSTGRES_PASSWORD=${POSTGRESQL_PASSWORD}
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge
    name: sonarnet

volumes:
  sonarqube_conf:
    driver: local
    name: sonarqube_conf
  sonarqube_data:
    driver: local
    name: sonarqube_data
  sonarqube_extensions:
    driver: local
    name: sonarqube_extensions
  sonarqube_bundled-plugins:
    driver: local
    name: sonarqube_bundled-plugins
  postgresql:
    driver: local
    name: sonarqube_postgresql
  postgresql_data:
    driver: local
    name: sonarqube_postgresql_data
"> $HOME_PATH/sonarqube/docker-compose.yaml
}

change_admin_password(){
echo "Create Admin User"

WARMING_TIME=20
TIME_OUT=100
INTERVAL=5
COUNT=1
RETRY_COUNT=$((TIME_OUT / INTERVAL))

while true; do
    http_status=$(request_change_password_api)
    if [[ "$http_status" -eq 204 ]] || [[ "$http_status" -eq 401 ]]; then
        break
    fi
    if [ $COUNT -eq $RETRY_COUNT ]; then
        echo "$(date +"%Y-%m-%d %H:%M:%S") URL: $URL Timeout!" >&2
        exit 1
    fi
    (( COUNT++ ))
    sleep $INTERVAL
done
}

request_change_password_api(){
     http_status=$(curl -i -o - --silent \
    -X POST -u ${ADMIN_USER}:admin \
    "http://localhost:${SONARQUBE_PORT}${URL_PREFIX}/api/users/change_password?login=$ADMIN_USER&previousPassword=admin&password=$ADMIN_PASSWORD" \
    | grep HTTP |  awk '{print $2}')
    echo "$http_status"
}


install_sonarqube(){
 docker-compose -f $HOME_PATH/sonarqube/docker-compose.yaml up -d
}


# Let's go ###################################################################################
configure_docker_host
prepare_sonarqube
create_docker_ignore
create_docker_compose_file
install_sonarqube
change_admin_password
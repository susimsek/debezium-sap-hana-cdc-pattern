#
#
# make get_libs     - build the go binary
# make docker_build - build the docker image
#

DOCKER_TAG ?= 1.2
REPO_URL = https://repo1.maven.org/maven2

.PHONY: get_libs
get_libs:
	@echo "Getting jar files into target ..."
	@mkdir -p target
	@while read -r line; do wget $(REPO_URL)/$$line -P target; done<libs.txt

.PHONY: docker_build
docker_build:
	@echo "Building docker image ..."
	docker build . -t debezium-connector-hana-min:$(DOCKER_TAG)
